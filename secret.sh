#!/bin/sh

#SECRET_DRIVE
#SECRET_NAME
#SECRET_MOUNT
#PARTUUID

die "please configure with ./configure"

die() {
   echo "$1"
   exit 1
}

[ $(id -u) -ne 0 ] && die "superuser access required."

while true; do
   sleep 10

   echo "Waiting for key..."

   drive=$(blkid | grep "PARTUUID=\"${PARTUUID}\"" | cut -d':' -f1)

   # Check if the drive is inserted
   [ -z "${drive}" ] && continue

   # Size must be 1M
   [ "$(lsblk | awk "/$(basename "${drive}")/{print \$4}")" != "1M" ] && continue

   echo "Key inserted"

   # Unlock secret
   cryptsetup open "${SECRET_DRIVE}" "${SECRET_NAME}" --key-file="${drive}"
   [ $? -ne 0 ] && echo "failed to unlock secret" && sleep 50 && continue

   echo "Unlocked secret"

   # Mount secret
   mkdir -p "${SECRET_MOUNT}"
   mount "/dev/mapper/${SECRET_NAME}" "${SECRET_MOUNT}"
   if [ $? -ne 0 ]; then
      echo "failed to mount secret"
      cryptsetup close "${SECRET_NAME}"
      sleep 50
      continue
   fi

   echo "Mounted secret"

   # Wait for the drive to be removed
   while blkid | grep -q "PARTUUID=\"${PARTUUID}\""; do
      sleep 3
   done

   echo "Key removed"

   # Unmount secret
   umount "/dev/mapper/${SECRET_NAME}" >&2 2>/dev/null
   if [ $? -ne 0 ]; then
      echo "Failed to unmount secret, forcing unmount"
      fuser -s -k "${SECRET_MOUNT}"
      sleep 1
      if fuser -s "${SECRET_MOUNT}"; then
         echo "Killing the rest of them"
         fuser -s -k -9 "${SECRET_MOUNT}"
      fi
      if ! umount "/dev/mapper/${SECRET_NAME}"; then
         die "Failed to unmount secret!"
      fi
   fi

   echo "Unmounted secret"

   # Lock secret
   cryptsetup close "${SECRET_NAME}"

   echo "Locked secret"

   sleep 110
done
