#!/usr/bin/env nix-shell
#! nix-shell -i bash -p bc

# Generate multiple Plymouth themes using both approaches

# Theme configurations
declare -A themes=(
    ["evil-nix"]="local"
    ["rainbow-nix"]="genix7000"
    ["pride-nix"]="genix7000"
)

# Color schemes
declare -A colors=(
    ["evil-nix"]="#cc0000 #990000 #660000"
    ["rainbow-nix"]="#ff0000 #ff7f00 #ffff00 #00ff00 #0000ff #4b0082 #9400d3"
    ["pride-nix"]="#e40303 #ff8c00 #ffed00 #008018 #004cff #732982"
)

generate_local_theme() {
    local theme_name=$1
    local scad_file="good-logo.scad"  # Using the good version
    
    echo "Generating ${theme_name} using local OpenSCAD..."
    
    # Modify the good-logo.scad for evil-nix colors
    if [ "$theme_name" == "evil-nix" ]; then
        sed 's/colors = \["#5277c3", "#7caedc"\];/colors = ["#cc0000", "#990000"];/' \
            "$scad_file" > "temp-${theme_name}.scad"
        scad_file="temp-${theme_name}.scad"
    else
        scad_file="good-logo.scad"
    fi
    
    mkdir -p "${theme_name}-plymouth"
    
    # Generate 30 frames for smoother animation
    for i in $(seq 0 29); do
        t=$(echo "scale=6; $i / 29" | bc -l)
        echo "Frame $((i+1))/30 (t=${t})"
        
        openscad -o "${theme_name}-frame-${i}.svg" \
            -D "\$t=${t}" \
            --export-format=svg \
            --imgsize=400,400 \
            "$scad_file"
        
        if [ -f "${theme_name}-frame-${i}.svg" ]; then
            convert "${theme_name}-frame-${i}.svg" \
                -background black \
                -flatten \
                -resize 200x200 \
                "${theme_name}-plymouth/$(printf "%03d.png" $((i+1)))"
            rm "${theme_name}-frame-${i}.svg"
        fi
    done
    
    # Cleanup temp file
    [ -f "temp-${theme_name}.scad" ] && rm "temp-${theme_name}.scad"
}

generate_genix7000_theme() {
    local theme_name=$1
    local color_string=${colors[$theme_name]}
    
    echo "Generating ${theme_name} using genix7000..."
    mkdir -p "${theme_name}-plymouth"
    
    # Create animation using genix7000
    nix run github:cab404/genix7000#to-image -- \
        "${theme_name}.mp4" \
        $color_string \
        --animation '{ rotation: ($rotation - $i * 3) }' \
        --duration 2 \
        --fps 15 \
        --imgsize "400,400"
    
    # Extract frames if MP4 was created
    if [ -f "${theme_name}.mp4" ]; then
        ffmpeg -i "${theme_name}.mp4" \
            -vf "scale=200:200" \
            "${theme_name}-plymouth/%03d.png" 2>/dev/null
        rm "${theme_name}.mp4"
    else
        echo "MP4 generation failed, trying individual frames..."
        # Fallback to individual frame generation
        for i in $(seq 0 29); do
            rotation=$((i * 12))  # 360/30 frames
            nix run github:cab404/genix7000#to-image -- \
                "${theme_name}-frame-${i}.png" \
                $color_string \
                --rotation "$rotation" \
                --imgsize "200,200"
            
            if [ -f "${theme_name}-frame-${i}.png" ]; then
                mv "${theme_name}-frame-${i}.png" \
                   "${theme_name}-plymouth/$(printf "%03d.png" $((i+1)))"
            fi
        done
    fi
}

create_plymouth_files() {
    local theme_name=$1
    local frame_count=$(ls "${theme_name}-plymouth"/*.png 2>/dev/null | wc -l)
    
    echo "Creating Plymouth configuration for ${theme_name} (${frame_count} frames)"
    
    # Create .plymouth file
    cat > "${theme_name}-plymouth/${theme_name}.plymouth" << EOF
[Plymouth Theme]
Name=${theme_name}
Description=${theme_name^} Nix Logo Animation
Comment=Animated Nix logo theme for boot splash
ModuleName=script

[script]
ImageDir=/usr/share/plymouth/themes/${theme_name}
ScriptFile=/usr/share/plymouth/themes/${theme_name}/${theme_name}.script
EOF

    # Create .script file
    cat > "${theme_name}-plymouth/${theme_name}.script" << EOF
# ${theme_name^} Plymouth Theme

image_quantity = ${frame_count};
frame_rate = 15;
frame_counter = 0;
current_frame = 1;

# Load frames
for (i = 1; i <= image_quantity; i++)
{
    frame_image[i] = Image(sprintf("%03d.png", i));
}

# Create and position sprite
logo_sprite = Sprite();
logo_sprite.SetImage(frame_image[1]);

logo_width = frame_image[1].GetWidth();
logo_height = frame_image[1].GetHeight();
logo_sprite.SetX(Window.GetX() + (Window.GetWidth() / 2 - logo_width / 2));
logo_sprite.SetY(Window.GetY() + (Window.GetHeight() / 2 - logo_height / 2));

# Animation
fun refresh_callback()
{
    frame_counter++;
    if (frame_counter % (60 / frame_rate) == 0)
    {
        current_frame++;
        if (current_frame > image_quantity)
            current_frame = 1;
        logo_sprite.SetImage(frame_image[current_frame]);
    }
}

Plymouth.SetRefreshFunction(refresh_callback);

# LUKS messages
fun message_callback(text)
{
    if (text)
    {
        message_image = Image.Text(text, 1, 1, 1);
        message_sprite = Sprite(message_image);
        message_sprite.SetX(Window.GetX() + (Window.GetWidth() / 2 - message_image.GetWidth() / 2));
        message_sprite.SetY(logo_sprite.GetY() + logo_height + 30);
    }
}

Plymouth.SetMessageFunction(message_callback);
EOF

    # Create install script
    cat > "${theme_name}-plymouth/install.sh" << EOF
#!/bin/bash
sudo cp -r . /usr/share/plymouth/themes/${theme_name}/
sudo plymouth-set-default-theme ${theme_name}
sudo update-initramfs -u
echo "${theme_name^} Plymouth theme installed!"
EOF
    
    chmod +x "${theme_name}-plymouth/install.sh"
}

# Main execution
echo "Plymouth Multi-Theme Generator"
echo "=============================="

for theme in "${!themes[@]}"; do
    echo "Processing theme: $theme"
    
    case ${themes[$theme]} in
        "local")
            generate_local_theme "$theme"
            ;;
        "genix7000")
            generate_genix7000_theme "$theme"
            ;;
    esac
    
    create_plymouth_files "$theme"
    echo "Completed: ${theme}-plymouth/"
    echo ""
done

echo "All themes generated!"
echo "Available themes:"
for theme in "${!themes[@]}"; do
    echo "  - ${theme} (${themes[$theme]})"
done