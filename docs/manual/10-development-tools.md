# Development Tools

## Shell Functions

Omarchy provides several shell functions designed to streamline common operational tasks.

### File Compression
- `compress [file.tar.gz]` - Create a tar.gz file
- `decompress [file.tar.gz]` - Expand a tar.gz file

### Storage Operations
- `iso2sd [image.iso] [/path/to/sdcard]` - Create a bootable drive on an SD card using the referenced iso file
- `format-drive [/dev/drive]` - Format an entire disk with a single exFAT partition (which works on Windows and macOS too). **Be careful!**

### Image Conversion
- `img2jpg` - Turn any image into a near-full quality jpg
- `img2jpg-small` - Turn any image into near-full quality 1080p-wide jpg
- `img2png` - Turn any image into a lossly-compressed PNG
