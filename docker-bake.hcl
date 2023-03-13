group "default" {
  targets = ["build-php", "php", "php-fpm", "console-zip", "console", "php-fpm-dev"]
}

variable "CPU" {
  default = "x86"
}
variable "PHP_VERSION" {
  default = "80"
}
variable "IMAGE_VERSION_SUFFIX" {
  default = "x86_64"
}
variable "DOCKER_PLATFORM" {
  default = "linux/amd64"
}

target "build-php" {
  dockerfile = "php-${PHP_VERSION}/Dockerfile"
  target = "build-environment"
  tags = ["bref/build-php-${PHP_VERSION}"]
  args = {
    "IMAGE_VERSION_SUFFIX" = "${IMAGE_VERSION_SUFFIX}"
  }
  platforms = ["${DOCKER_PLATFORM}"]
}

target "php" {
  dockerfile = "php-${PHP_VERSION}/Dockerfile"
  target = "function"
  tags = ["bref/php-${PHP_VERSION}"]
  args = {
    "IMAGE_VERSION_SUFFIX" = "${IMAGE_VERSION_SUFFIX}"
  }
  contexts = {
    "bref/build-php-${PHP_VERSION}" = "target:build-php"
  }
  platforms = ["${DOCKER_PLATFORM}"]
}

target "php-fpm" {
  dockerfile = "php-${PHP_VERSION}/Dockerfile"
  target = "fpm"
  tags = ["bref/php-${PHP_VERSION}-fpm"]
  args = {
    "IMAGE_VERSION_SUFFIX" = "${IMAGE_VERSION_SUFFIX}"
  }
  contexts = {
    "bref/build-php-${PHP_VERSION}" = "target:build-php"
    "bref/php-${PHP_VERSION}" = "target:php"
  }
  platforms = ["${DOCKER_PLATFORM}"]
}

target "console-zip" {
  context = "layers/console"
  target = "console-zip"
  tags = ["bref/console-zip"]
  args = {
    PHP_VERSION = "${PHP_VERSION}"
  }
  platforms = ["${DOCKER_PLATFORM}"]
}

target "console" {
  context = "layers/console"
  target = "console"
  tags = ["bref/php-${PHP_VERSION}-console"]
  args = {
    PHP_VERSION = "${PHP_VERSION}"
  }
  contexts = {
    "bref/build-php-${PHP_VERSION}" = "target:build-php"
    "bref/php-${PHP_VERSION}" = "target:php"
  }
  platforms = ["${DOCKER_PLATFORM}"]
}

target "php-fpm-dev" {
  context = "layers/fpm-dev"
  tags = ["bref/php-${PHP_VERSION}-fpm-dev"]
  args = {
    PHP_VERSION = "${PHP_VERSION}"
    "CPU" = "${CPU}"
  }
  contexts = {
    "bref/build-php-${PHP_VERSION}" = "target:build-php"
    "bref/php-${PHP_VERSION}" = "target:php"
    "bref/php-${PHP_VERSION}-fpm" = "target:php-fpm"
    "bref/local-api-gateway" = "docker-image://bref/local-api-gateway:latest"
  }
  platforms = ["${DOCKER_PLATFORM}"]
}
