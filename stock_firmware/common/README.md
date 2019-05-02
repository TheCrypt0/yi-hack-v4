In this folder should be a file named "pub_key", the public RSA key that Xiaomi provides with the camera needed to decrypt the stock firmware updates.

Like the stock firmware, I won't provide it because of legal reasons.

The easy way is to just copy it from the camera:

```
scp root@IP_OF_YOUR_CAMERA:/home/base/tools/pub_key ./pub_key
```

