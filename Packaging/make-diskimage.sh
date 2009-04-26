# Create a read-only disk image of the contents of a folder
#
# Usage: make-diskimage <image_file>
#                       <src_folder>
#                       <volume_name>
#                       <applescript>
#                       <eula_resource_file>

set -e;

OPENUP_TOOL=openUp/openUp
SETFILE_TOOL=/Developer/Tools/SetFile

DMG_DIRNAME=`dirname $1`
DMG_DIR=`cd $DMG_DIRNAME > /dev/null; pwd`
DMG_NAME=`basename $1`
DMG_TEMP_NAME=${DMG_DIR}/rw.${DMG_NAME}
SRC_FOLDER=`cd $2 > /dev/null; pwd`
VOLUME_NAME=$3

APPLESCRIPT=$4
EULA_RSRC=$5

# Create the image
echo "creating disk image"
rm -f $DMG_TEMP_NAME
hdiutil create -srcfolder $SRC_FOLDER -volname $VOLUME_NAME -fs HFS+ -fsargs "-c c=64,a=16,e=16" -format UDRW $DMG_TEMP_NAME

# mount it
echo "mounting disk image"
MOUNT_DIR=/Volumes/$VOLUME_NAME
hdiutil attach -readwrite -noverify -noautoopen $DMG_TEMP_NAME

# run applescript
if [ ! -z "${APPLESCRIPT}" -a "${APPLESCRIPT}" != "-null-" ]; then
	osascript $APPLESCRIPT
fi

# make sure it's not world writeable
echo "fixing permissions for \"${MOUNT_DIR}\""
chmod -Rf go-w "${MOUNT_DIR}" || true
chmod -f a-w "${MOUNT_DIR}"/.DS_Store || true

# make the top window open itself on mount:
if [ -x ${OPENUP_TOOL} ]; then
	echo "setting auto open flag"
    ${OPENUP_TOOL} "${MOUNT_DIR}"
fi

if [ -f "${MOUNT_DIR}/.VolumeIcon.icns" ]; then
	echo "setting icon for \"${MOUNT_DIR}\""
	${SETFILE_TOOL} -a C "${MOUNT_DIR}"
fi

# unmount
echo "unmounting disk image"
hdiutil detach $MOUNT_DIR

# compress image
echo "compressing disk image"
hdiutil convert $DMG_TEMP_NAME -format UDZO -imagekey zlib-level=9 -o ${DMG_DIR}/${DMG_NAME}
rm -f $DMG_TEMP_NAME

# adding EULA resources
if [ ! -z "${EULA_RSRC}" -a "${EULA_RSRC}" != "-null-" ]; then
        echo "adding EULA resources"
        hdiutil unflatten ${DMG_DIR}/${DMG_NAME}
        /Developer/Tools/ResMerger -a ${EULA_RSRC} -o ${DMG_DIR}/${DMG_NAME}
        hdiutil flatten ${DMG_DIR}/${DMG_NAME}
fi

echo "disk image done"
exit 0
