
# Tagging the Image

### Tags for versioning

Tagging allows you to provide or label specific versions of an image. This is especially useful when you deploy a specific version and if something goes wrong, you can easily roll back to previous version.

### Tags as aliases

These are simple aliases which can be given to a docker image before or after building an image. If you don't provide a tag, docker automatically gives the image a "latest" tag.

### Tags must be an ASCII character string

It may also include lowercase and uppercase letters, digits, underscores, periods, and dashes. In addition, the tag names must not begin with a period or a dash, and they can only contain 128 characters.

### Images can also have more than one tag

Docker images can have multiple tags assigned to them. It may appear as different images when you run the <code>docker images</code> command but notice that they all point to the same image ID.

### Tag before pushing the image to a container registry

It is highly recommended to tag the image first before pushing an image to a Docker registry. Without the tagging, the image would be allocated with a random ID during the build stage.



<br>

[Back to first page](../../README.md#docker--containers)