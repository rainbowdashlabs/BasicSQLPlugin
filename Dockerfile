FROM python:3.11-bullseye AS base

COPY . .
RUN pip install mkdocs-material && pip install mkdocs-git-revision-date-localized-plugin

RUN find docs/ -type f -print0 | xargs -0 sed -i 's/```mariadb/```sql/g'
RUN find docs/ -type f -print0 | xargs -0 sed -i 's/```mysql/```sql/g'
RUN find docs/ -type f -print0 | xargs -0 sed -i 's/```sqlite/```sql/g'
RUN find docs/ -type f -print0 | xargs -0 sed -i 's/```postgresql/```sql/g'

RUN mkdocs build

FROM nginx:alpine

COPY --from=base /site /usr/share/nginx/html

EXPOSE 80
