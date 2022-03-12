FROM {{ image }}

ARG proget_url
ARG makedeb_package
ARG DEBIAN_FRONTEND=noninteractive

# Install needed packages.
RUN apt-get update
RUN apt-get dist-upgrade -y
RUN apt-get install wget gpg sudo -y

# Install makedeb.
RUN wget -qO - "https://${proget_url}/debian-feeds/makedeb.pub" | \
    gpg --dearmor | \
    tee /usr/share/keyrings/makedeb-archive-keyring.gpg 1> /dev/null

RUN echo "deb [signed-by=/usr/share/keyrings/makedeb-archive-keyring.gpg arch=all] https://${proget_url}/ makedeb main" | \
    tee /etc/apt/sources.list.d/makedeb.list

RUN apt-get update
RUN apt-get install "${makedeb_package}" -y

# Set up default build user.
RUN useradd -m makedeb
RUN echo 'makedeb ALL=(ALL:ALL) NOPASSWD:ALL' >> /etc/sudoers
USER makedeb

WORKDIR /home/makedeb/
ENTRYPOINT ["/bin/bash"]