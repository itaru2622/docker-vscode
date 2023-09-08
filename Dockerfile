#cf. https://github.com/cmiles74/docker-vscode/blob/master/Dockerfile

ARG base=debian:bookworm
FROM ${base}
ARG base

# use bash instead of sh in RUN command
SHELL ["/bin/bash", "-c"]

RUN apt update
#RUN apt install -y curl apt-transport-https gnupg2
RUN curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add - ;\
    echo "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list;
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
RUN apt update

# install python3-pip and dependencies only when base image is not based on python
RUN if [[ ${base} != python* ]] ; \
    then \
        apt install -y python3-pip; \
    fi

RUN apt install -y code git make bash-completion jq nodejs \
                   task-japanese locales-all locales ibus-mozc sudo dante-client connect-proxy vim iputils-ping traceroute net-tools tzdata \
                   parallel

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
    pip3 install fastapi[standard] uvicorn[standard]      yq pandas openpyxl numpy sympy   q pytest pytest-cov httpx

RUN pip3 install sympy \
                 matplotlib \
                 pymongo jupyterlab 

# converter between JsonSchema <=> OpenAPI
RUN npm install -g typescript \
                   @openapi-contrib/json-schema-to-openapi-schema @openapi-contrib/openapi-schema-to-json-schema

# python class generator from JsonSchema
RUN pip3 install  git+https://github.com/koxudaxi/datamodel-code-generator.git

# UML generator from python class (pyreverse@pylint), with re-formater mermaid (text2img @ github support), and graphviz
RUN pip3 install   pylint; \
    apt install -y graphviz; \
    npm install -g @mermaid-js/mermaid-cli

ENV PATH ${PATH}:./node_modules/.bin:/usr/lib/node_modules/.bin:/usr/lib/node_modules/@openapi-contrib/json-schema-to-openapi-schema/bin:

# install nlp things and etc.
#RUN pip3 install fastapi uvicorn[standard] q pytest pytest-cov httpx pandas spacy; \
#    python3 -m spacy download    en_core_web_lg;

USER ${uname}
#ENV HOME /home/${uname}

# install vscode plugin...
RUN code --install-extension      ms-python.python; \
    code --install-extension      MS-CEINTL.vscode-language-pack-ja; \
    code --install-extension      ms-vscode-remote.vscode-remote-extensionpack; \
    sudo code --install-extension ms-vscode.js-debug    --no-sandbox --user-data-dir;

VOLUME  ${workdir} /home/${uname}/.ssh /home/${uname}/.vscode
WORKDIR ${workdir}

#CMD code
