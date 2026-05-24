FROM gvenzl/oracle-xe:21-slim-faststart

ENV ORACLE_PASSWORD=admin
ENV APP_USER=mon_user
ENV APP_USER_PASSWORD=mon_mdp

COPY ./scripts/*.sql /container-entrypoint-initdb.d/

EXPOSE 1521 5500