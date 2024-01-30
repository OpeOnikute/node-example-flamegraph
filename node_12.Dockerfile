FROM node:12.22.1

WORKDIR /usr/src/app

RUN LINUX_NUM=$(uname -r | cut -d'.' -f1) && \
    # Gets the Linux version and strips out the 'linuxkit' part
    LINUX_VER=$(uname -r | cut -d'.' -f1-3 | cut -d'-' -f1) && \
    # Downloads compressed linux-tools for the version
    wget "https://cdn.kernel.org/pub/linux/kernel/v$LINUX_NUM.x/linux-$LINUX_VER.tar.xz" && \
    tar -xf "./linux-$LINUX_VER.tar.xz" && cd "linux-$LINUX_VER/tools/perf/" && \
    # Install libelf-dev or `perf probe` gets disabled
    apt-get update && apt -y install python-dev flex bison ocaml \ 
        libelf-dev libdw-dev systemtap-sdt-dev libunwind-dev \
        libperl-dev binutils-dev libzstd-dev libcap-dev \
        libnuma-dev libbabeltrace-dev && \
    make -C . && make install && \
    # copy perf into the executable path. Works as long as "/usr/local/bin"
    # is in the $PATH variable
    cp perf /usr/local/bin

RUN npm i -g stackvis

COPY package*.json ./

RUN npm install

COPY app.js container*.sh ./

VOLUME ["/out"]

EXPOSE 8082

ENTRYPOINT ["node", "--perf_basic_prof_only_functions", "app.js"]