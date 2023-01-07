#cf. https://github.com/cmiles74/docker-vscode/blob/master/Dockerfile

From debian:bullseye

RUN apt update
RUN apt install -y curl apt-transport-https gnupg2
RUN curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add - ;\
    echo "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list;
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
RUN apt update
RUN apt install -y code git make python3 python3-pip bash-completion jq nodejs \
                   task-japanese locales-all locales ibus-mozc sudo dante-client connect-proxy vim

ARG uid=1000
ARG uname=vscode
ARG workdir=/work
RUN mkdir -p ${workdir} ; \
    addgroup --system --gid ${uid} ${uname} ; \
    adduser  --system --gid ${uid} --uid ${uid} --shell /bin/bash ${uname} ; \
    echo "${uname}:${uname}" | chpasswd; \
    (cd /etc/skel; find . -type f -print | tar cf - -T - | tar xvf - -C/home/${uname} ) ; \
    echo "${uname} ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/local-user; \
    mkdir -p /home/${uname}/.ssh ;\
    chown -R ${uname} /home/${uname} ${workdir}; \
    echo "ja_JP.UTF-8 UTF-8" > /etc/locale.gen; locale-gen; update-locale LANG=ja_JP.UTF-8 LANGUAGE="ja_JP:ja"

RUN pip3 install  fastapi uvicorn[standard] q pytest pytest-cov httpx

# install nlp things and etc.
#RUN pip3 install fastapi uvicorn[standard] q pytest pytest-cov httpx pandas spacy; \
#    python3 -m spacy download    en_core_web_lg;
#
# install heideltime, resolving MM-DD to YYYY-MM-DD
#RUN apt install -y openjdk-11-jre ; \
#   pip3 install git+https://github.com/JMendes1995/py_heideltime.git; \
#   chmod a+rx /usr/local/lib/python3.9/dist-packages/py_heideltime/Heideltime/TreeTaggerLinux/bin/*

USER ${uname}

# install vscode plugin...
RUN code --install-extension  ms-python.python; \
    code --install-extension  MS-CEINTL.vscode-language-pack-ja; \
    code --install-extension  ms-vscode-remote.vscode-remote-extensionpack; \
    code --install-extension  waderyan.nodejs-extension-pack;

VOLUME  ${workdir} /home/${uname}/.ssh /home/${uname}/.vscode
WORKDIR ${workdir}

#CMD code
