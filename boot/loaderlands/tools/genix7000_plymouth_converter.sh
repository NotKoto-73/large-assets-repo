#!/usr/bin/env nix-shell
#! nix-shell -i bash -p ffmpeg openscad

# Convert genix7000 to Plymouth evil-nix theme

THEME_NAME="evil-nix"
COLORS=("#cc0000" "#990000" "#660000")  # Evil red gradient

mkdir -p "${THEME_NAME}-plymouth"

echo "Generating evil-nix Plymouth theme using genix7000..."

# Check if genix7000 is available
if ! command -v nix &> /dev/null; then
    echo "Error: nix command not found. Please install Nix."
    exit 1
fi

# Generate individual frames instead of animation
echo "Creating frames with genix7000..."
FRAME_COUNT=24
for i in $(seq 0 $((FRAME_COUNT-1))); do
    # Calculate rotation for this frame
    ROTATION=$((i * 360 / FRAME_COUNT))
    
    echo "Generating frame $((i+1))/${FRAME_COUNT} (rotation: ${ROTATION}°)"
    
    # Generate individual frame
    nix run github:cab404/genix7000#to-image -- \
        "${THEME_NAME}-frame-${i}.png" \
        "${COLORS[0]}" "${COLORS[1]}" "${COLORS[2]}" \
        --rotation "${ROTATION}" \
        --thick 20 \
        --num 5 \
        --imgsize "200,200"
    
    # Move and rename to sequential format
    if [ -f "${THEME_NAME}-frame-${i}.png" ]; then
        mv "${THEME_NAME}-frame-${i}.png" "${THEME_NAME}-plymouth/$(printf "%03d.png" $((i+1)))"
    else
        echo "Warning: Failed to generate frame $i"
    fi
done

# Count actual frames generated
ACTUAL_FRAMES=$(ls "${THEME_NAME}-plymouth"/*.png 2>/dev/null | wc -l)
echo "Generated ${ACTUAL_FRAMES} frames"

# Create Plymouth theme files
cat > "${THEME_NAME}-plymouth/${THEME_NAME}.plymouth" << EOF
[Plymouth Theme]
Name=${THEME_NAME}
Description=Evil Nix - Animated Nix logo with dark red theme
Comment=Generated from genix7000 with evil aesthetic
ModuleName=script

[script]
ImageDir=/usr/share/plymouth/themes/${THEME_NAME}
ScriptFile=/usr/share/plymouth/themes/${THEME_NAME}/${THEME_NAME}.script
EOF

# Create Plymouth script with proper animation
cat > "${THEME_NAME}-plymouth/${THEME_NAME}.script" << EOF
# Evil Nix Plymouth Theme - Animated Logo

# Animation settings
image_quantity = ${ACTUAL_FRAMES};
frame_rate = 12;
frame_counter = 0;
current_frame = 1;

# Load all animation frames
for (i = 1; i <= image_quantity; i++)
{
    frame_image[i] = Image(sprintf("%03d.png", i));
}

# Create sprite and position it
evil_nix_sprite = Sprite();
evil_nix_sprite.SetImage(frame_image[1]);

# Center the logo horizontally and vertically
logo_width = frame_image[1].GetWidth();
logo_height = frame_image[1].GetHeight();
evil_nix_sprite.SetX(Window.GetX() + (Window.GetWidth() / 2 - logo_width / 2));
evil_nix_sprite.SetY(Window.GetY() + (Window.GetHeight() / 2 - logo_height / 2));

# Animation refresh function
fun refresh_callback()
{
    frame_counter++;
    
    # Update frame based on frame rate (assuming 60 FPS base)
    if (frame_counter % (60 / frame_rate) == 0)
    {
        current_frame++;
        if (current_frame > image_quantity)
            current_frame = 1;
        
        evil_nix_sprite.SetImage(frame_image[current_frame]);
    }
}

Plymouth.SetRefreshFunction(refresh_callback);

# Handle LUKS password prompts
fun message_callback(text)
{
    if (text)
    {
        message_image = Image.Text(text, 0.8, 0.8, 0.8);
        message_sprite = Sprite(message_image);
        message_sprite.SetX(Window.GetX() + (Window.GetWidth() / 2 - message_image.GetWidth() / 2));
        message_sprite.SetY(evil_nix_sprite.GetY() + logo_height + 30);
    }
}

Plymouth.SetMessageFunction(message_callback);
EOF

# Installation script
cat > "${THEME_NAME}-plymouth/install.sh" << EOF
#!/bin/bash
sudo cp -r . /usr/share/plymouth/themes/${THEME_NAME}/
sudo plymouth-set-default-theme ${THEME_NAME}
sudo update-initramfs -u
echo "Evil Nix Plymouth theme installed!"
EOF

chmod +x "${THEME_NAME}-plymouth/install.sh"

echo "Evil Nix Plymouth theme created in: ${THEME_NAME}-plymouth/"
echo "To install: cd ${THEME_NAME}-plymouth && sudo ./install.sh"
