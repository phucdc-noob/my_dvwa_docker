# dvwa_docker
just a shitty docker, nvm

## How to use?

- Install [docker engine](https://docs.docker.com/engine/install/) and [docker-compose](https://docs.docker.com/compose/install/) on your machine
- Clone this repo:
  ```bash
  git clone https://github.com/phucdc-noob/my_dvwa_docker.git dvwa_docker
  cd dvwa_docker
  ```
- Run the first time:
  ```bash
  docker-compose up --build
  ```
- Now you can go to [http://localhost:8888/](http://localhost:8888/) and setup your DVWA.
- Keep the terminal that run the `docker-compose` command! If you turn it off, you can open it again by:
  ```bash
  docker-compose up
  ```
