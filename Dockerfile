FROM python:buster

ARG user=kong
ARG group=docker

ENV HOME=/home/$user
RUN \
  groupadd --force "$group" \
  && \
  {  \
  getent passwd $user || \
  useradd -m -d $HOME -N -g ${group} \
          -c "Non-priv'd User" -p "!disabled!" "$user" \
  ; } 

USER ${user}:${group}

WORKDIR /src
COPY / /src
ENV FLASK_APP main.py

EXPOSE 5000

USER root
RUN make install

ENTRYPOINT ["/src/.venv/bin/flask"]
CMD ["run", "--host=0.0.0.0"]
