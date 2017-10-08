FROM debian:jessie

# Turn off interactive installs
# See https://github.com/phusion/baseimage-docker/issues/58
ENV DEBIAN_FRONTEND noninteractive

RUN apt-key adv --keyserver keys.gnupg.net --recv-key 'E19F5F87128899B192B1A2C2AD5F960A256A04AF' \
 && echo "deb http://cran.rstudio.com/bin/linux/debian jessie-cran34/" >> /etc/apt/sources.list \
 && apt-get update \
 && apt-get install -y \
    libcurl4-openssl-dev \
    libssh2-1-dev \
    libssl-dev \
    libxml2-dev \
    r-base \
    r-base-dev \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/

# Create and switch to guest user
RUN useradd --create-home --shell /bin/bash guest
WORKDIR /home/guest
USER guest

# Image specification files
RUN mkdir .image
COPY Dockerfile .image/
COPY r-packages-install.R .image/
COPY r-packages-rho.txt .image/

# Copy and run R package installation files
ENV R_LIBS_USER /home/guest/.r-packages
RUN mkdir $R_LIBS_USER && Rscript .image/r-packages-install.R .image/r-packages-rho.txt

# README as fallback document
COPY README.md .

# Run R Stencila Host
CMD ["Rscript", "-e", "stencila:::run('0.0.0.0', 2000)"]
