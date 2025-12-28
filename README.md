## basic use example on linux

```bash
yourhost$ work_dir=${HOME}/yourProjectDir
yourhost$ docker run --name vscode -v ${work_dir}:/work -v /tmp/.X11-unix:/tmp/.X11-unix --rm --network host --privileged -e DISPLAY=${DISPLAY}  itaru2622/vscode:trixie code
```

note: in some case, vscode failed starting. in that case, try below:

```bash
yourhost$ work_dir=${HOME}/yourProjectDir
yourhost$ docker run -it --name vscode -v ${work_dir}:/work -v /tmp/.X11-unix:/tmp/.X11-unix --rm --network host --privileged -e DISPLAY=${DISPLAY}  itaru2622/vscode:trixie /bin/bash

container$ code
```

## use vscode with chrome(dbus)
```bash
yourhost$ work_dir=${HOME}/yourProjectDir

# share dbus folder between host and container
yourhost$ docker run -it --name vscode -v ${work_dir}:/work \
-v /var/run/dbus:/var/run/dbus \
-v /tmp/.X11-unix:/tmp/.X11-unix --rm --network host --privileged -e DISPLAY=${DISPLAY}  itaru2622/vscode:trixie /bin/bash

# start dbus-daemon first
container$ sudo -E /etc/init.d/dbus start

# run vscode or chrome
container$ google-chrome-stable
container$ code
```
