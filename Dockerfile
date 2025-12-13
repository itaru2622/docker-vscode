#cf. https://github.com/cmiles74/docker-vscode/blob/master/Dockerfile

ARG base=python:3.13-trixie
FROM ${base}
ARG base

# use bash instead of sh in RUN command
SHELL ["/bin/bash", "-c"]

#RUN apt install -y curl apt-transport-https gnupg2
ARG ver_node=22
RUN curl -L https://packages.microsoft.com/keys/microsoft.asc > /etc/apt/trusted.gpg.d/microsoft.asc; \
    echo "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list; \
    curl -fsSL https://deb.nodesource.com/setup_${ver_node}.x | bash - ; \
    curl -L https://dl.google.com/linux/linux_signing_key.pub | gpg --dearmor -o /etc/apt/trusted.gpg.d/google-linux-keyring.gpg; \
    echo "deb http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list ; \
    apt update

# install python3-pip and dependencies only when base image is not based on python
RUN if [[ ${base} != python* ]] ; \
    then \
        apt install -y python3-pip; \
    fi

ARG chrome=google-chrome-stable
RUN apt install -y code git make bash-completion tzdata task-japanese locales-all locales ibus-mozc sudo vim \
                   connect-proxy jq iputils-ping traceroute net-tools parallel \
                   nodejs upower ${chrome}; \
    npm install -g yarn pnpm typescript ts-node

ARG uid=1000
ARG uname=vscode
ARG workdir=/work
RUN mkdir -p ${workdir} ; \
    addgroup --system --gid ${uid} ${uname} ; \
    adduser  --system --gid ${uid} --uid ${uid} --shell /bin/bash --home /home/${uname} ${uname} ; \
    echo "${uname}:${uname}" | chpasswd; \
    (cd /etc/skel; find . -type f -print | tar cf - -T - | tar xvf - -C/home/${uname} ) ; \
    echo "${uname} ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/local-user; \
    mkdir -p /home/${uname}/.ssh ;\
    echo "set mouse-=a" > /home/${uname}/.vimrc; \
    chown -R ${uname}:${uname} /home/${uname} ${workdir}; \
    echo "ja_JP.UTF-8 UTF-8" > /etc/locale.gen; locale-gen; update-locale LANG=ja_JP.UTF-8 LANGUAGE="ja_JP:ja"

RUN pip3 install --upgrade pip; \
    pip3 install fastapi[standard] uvicorn watchfiles     yq pandas openpyxl numpy sympy   q pytest pytest-cov httpx

#RUN pip3 install jupyterlab  matplotlib pymongo

## converter between JsonSchema <=> OpenAPI
# RUN npm install -g typescript  @openapi-contrib/json-schema-to-openapi-schema @openapi-contrib/openapi-schema-to-json-schema

## python class generator from JsonSchema
# RUN pip3 install  git+https://github.com/koxudaxi/datamodel-code-generator.git

## UML generator from python class (pyreverse@pylint), with re-formater mermaid (text2img @ github support), and graphviz
# RUN pip3 install   pylint; \
#   apt install -y graphviz; \
#   npm install -g @mermaid-js/mermaid-cli

#ENV PATH ${PATH}:./node_modules/.bin:/usr/lib/node_modules/.bin:/usr/lib/node_modules/@openapi-contrib/json-schema-to-openapi-schema/bin:

## install nlp things and etc.
#RUN pip3 install fastapi uvicorn[standard] q pytest pytest-cov httpx pandas spacy; \
#    python3 -m spacy download    en_core_web_lg;

# dbus handling
#    update config file to avoid overwrite PIDFILE for host
RUN sed -i '/<pidfile>/c <pidfile>/tmp/dbus-pid-container</pidfile>' /usr/share/dbus-1/system.conf
#    config env cf. https://stackoverflow.com/questions/42898262/run-dbus-daemon-inside-docker-container
ENV DBUS_SESSION_BUS_ADDRESS="unix:path=/var/run/dbus/system_bus_socket"
#    to run dbus: sudo -E /etc/init.d/dbus start

USER ${uname}

## install vscode plugin...
RUN code --install-extension      ms-python.python; \
    code --install-extension      MS-CEINTL.vscode-language-pack-ja; \
    code --install-extension      ms-vscode-remote.vscode-remote-extensionpack; \
    code --install-extension      github.copilot; \
    code --install-extension ms-vscode.js-debug    --no-sandbox --user-data-dir;

VOLUME  ${workdir} /home/${uname}/.ssh /home/${uname}/.vscode
WORKDIR ${workdir}

#CMD code
