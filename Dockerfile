FROM swift:latest as builder
WORKDIR /root
COPY ./Package.* ./
RUN swift package resolve
COPY . .
RUN swift build -c release

FROM swift:slim
ENV PORT 4200
ENV HOST 0.0.0.0
EXPOSE 4200
COPY --from=builder /root/.build build
CMD ["build/release/FoamPit"]