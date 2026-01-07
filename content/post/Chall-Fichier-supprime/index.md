+++
author = "Enzo"
title = "Chall - Fichier supprimé"
date = "2026-01-05"
categories = [
    "Blue Team"
]
tags = [
    "USB",
    "Forensic",
    "CTF",
    "Chall",
    "Root-Me"
]
+++
## Introduction

Votre cousin a trouvé une clé USB à la bibliothèque ce matin. Il n’est pas très doué avec les ordinateurs, alors il compte sur vous pour retrouver le propriétaire de cette clé !

Le flag est l’identité du propriétaire sous la forme ``prénom_nom``

## Recherche
Quand nous téléchargeons le challenge, nous avons un fichier ``usb.images``. 
````Bash
ll

total 2160512
-rw-r--r--@ 1 enzo  staff   512M Jan 29  2013 ch2.dmp
-rw-r--r--@ 1 enzo  staff   512M Dec 28 20:02 cobalt_strike_hta.raw
-rw-rw----@ 1 enzo  staff    31M Sep 12  2021 usb.image
````

Nous commençons par un ``file`` pour savoir à quel type de dump nous affrontons. 
````Bash
file usb.image
usb.image: DOS/MBR boot sector, code offset 0x3c+2, OEM-ID "mkfs.fat", sectors/cluster 4, reserved sectors 4, root entries 512, sectors 63488 (volumes <=32 MB), Media descriptor 0xf8, sectors/FAT 64, sectors/track 62, heads 124, hidden sectors 2048, reserved 0x1, serial number 0xc7ecde5b, label: "USB        ", FAT (16 bit)
````

Pour finir le chall nous avons plusieurs méthodes, nous allons en voir 2. 
### Première méthode
````Bash
strings usb.image

mkfs.fat
USB        FAT16
This is not a bootable disk.  Please insert a bootable floppy and
press any key to try again ...
USB
my,S,S
my,S
NONYME PNG
zy,S,S
IHDR
gAMA
 cHRM
bKGD
iTXtXML:com.adobe.xmp
<?xpacket begin='
' id='W5M0MpCehiHzreSzNTczkc9d'?>
<x:xmpmeta xmlns:x='adobe:ns:meta/' x:xmptk='Image::ExifTool 11.88'>
<rdf:RDF xmlns:rdf='http://www.w3.org/1999/02/22-rdf-syntax-ns#'>
 <rdf:Description rdf:about=''
  xmlns:dc='http://purl.org/dc/elements/1.1/'>
  <dc:creator>
   <rdf:Seq>
    <rdf:li>Javier Turcot</rdf:li>
   </rdf:Seq>
  </dc:creator>
 </rdf:Description>
</rdf:RDF>
</x:xmpmeta>
<?xpacket end='r'?>'
IDATx
````

Ici nous voyons le début d'un secteur de fichier et à la ligne ``<rdf:li>`` nous pouvons voir le prénom et le nom.

### Deuxième méthode
Extration des docs avec ``foremost`` :
````Bash
foremost usb.image

foremost: /opt/homebrew/etc/foremost.conf: No such file or directory
Processing: usb.image
|*|
````

Une fois terminé nous avons un dossier output :
````Bash
ll

total 2160512
-rw-r--r--@ 1 enzo  staff   512M Jan 29  2013 ch2.dmp
-rw-r--r--@ 1 enzo  staff   512M Dec 28 20:02 cobalt_strike_hta.raw
drwxr-xr--@ 4 enzo  staff   128B Jan  5 11:17 output
-rw-rw----@ 1 enzo  staff    31M Sep 12  2021 usb.image
````
Nous nous rendons dedans : 
````Bash
cd output/png

ll

total 488
-rw-r--r--@ 1 enzo  staff   240K Jan  5 11:17 00000168.png

exiftool 00000168.png
ExifTool Version Number         : 13.44
File Name                       : 00000168.png
Directory                       : .
File Size                       : 246 kB
File Modification Date/Time     : 2026:01:05 11:17:34+01:00
File Access Date/Time           : 2026:01:05 11:17:36+01:00
File Inode Change Date/Time     : 2026:01:05 11:17:34+01:00
File Permissions                : -rw-r--r--
File Type                       : PNG
File Type Extension             : png
MIME Type                       : image/png
Image Width                     : 400
Image Height                    : 300
Bit Depth                       : 8
Color Type                      : RGB
Compression                     : Deflate/Inflate
Filter                          : Adaptive
Interlace                       : Noninterlaced
Gamma                           : 2.2
White Point X                   : 0.3127
White Point Y                   : 0.329
Red X                           : 0.64
Red Y                           : 0.33
Green X                         : 0.3
Green Y                         : 0.6
Blue X                          : 0.15
Blue Y                          : 0.06
Background Color                : 255 255 255
XMP Toolkit                     : Image::ExifTool 11.88
Creator                         : Javier Turcot
Image Size                      : 400x300
Megapixels                      : 0.120
````

Ici nous voyons le nom du "Creator" qui est le flag du challenge.