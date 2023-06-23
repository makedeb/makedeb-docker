FROM {{ image }}

ARG HW_URL
ARG MAKEDEB_PKGNAME
ARG DEBIAN_FRONTEND=noninteractive

# Install needed packages.
RUN apt-get update
RUN apt-get dist-upgrade -y
RUN apt-get install wget gpg sudo -y

# Install makedeb.
RUN wget -qO - "https://proget.${HW_URL}/debian-feeds/makedeb.pub" | \
    gpg --dearmor | \
    tee /usr/share/keyrings/makedeb-archive-keyring.gpg 1> /dev/null

RUN echo "deb [signed-by=/usr/share/keyrings/makedeb-archive-keyring.gpg arch=all] https://proget.${HW_URL}/ makedeb main" | \
    tee /etc/apt/sources.list.d/makedeb.list

RUN apt-get update
RUN apt-get install "${MAKEDEB_PKGNAME}" -y

# Set up default build user.
RUN useradd -m makedeb
RUN echo 'makedeb ALL=(ALL:ALL) NOPASSWD:ALL' >> /etc/sudoers
USER makedeb

WORKDIR /home/makedeb/
CMD ["/bin/bash"]
