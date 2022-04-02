# Blink

The staring game

# Logs Filter

When you running app you will see to many logs from facedetector. To remote them use filter below:

```
!V/faceDetectorV2Jni(*): detectFacesImageByteArray.*()
```

I think using filter is not good solution. Maybe you need to remove unnecessary logs at all.
