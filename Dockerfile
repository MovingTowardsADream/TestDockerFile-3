# Образ Alpine Linux версии 3.15
FROM alpine:3.15 as root-certs
# Установка пакета ca-certificates.
# Этот пакет содержит корневые сертификаты, необходимые для проверки подлинности SSL/TLS-соединений.
RUN apk add -U --no-cache ca-certificates
# Создается группа app с идентификатором 1001.
RUN addgroup -g 1001 app
# Создается пользователь app с идентификатором 1001 с домашней директорией /home/app.
RUN adduser app -u 1001 -D -G app /home/app

FROM golang:1.22 as builder
WORKDIR /youtube-api-files
# Корневые сертификаты копируются внутрь образа builder в директорию /etc/ssl/certs/.
COPY --from=root-certs /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs
COPY . .
# Сборка приложения. Опция -mod=vendor указывает на использование зависимостей, находящихся в папке vendor.
# (требуется прописать go mod vendor для создания папки с зависимостями приложения)
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -mod=vendor -o ./youtube-stats ./app/./...

FROM scratch as final
# Файлы /etc/passwd и /etc/group, скопированные во время этапа root-certs, копируются внутрь образа final.
COPY --from=root-certs /etc/passwd /etc/passwd
COPY --from=root-certs /etc/group /etc/group
# Корневые сертификаты, полученные в root-certs, копируются внутрь final в директорию /etc/ssl/certs/
COPY --chown=1001:1001 --from=root-certs /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs
# Исполняемый файл youtube-stats, скомпилированный во время этапа builder, копируется внутрь образа final
COPY --chown=1001:1001 --from=builder /youtube-api-files/youtube-stats /youtube-stats
# Устанавливает пользователя app
USER app
# Устанавливает команду, которая будет выполняться при запуске контейнера
ENTRYPOINT ["/youtube-stats"]