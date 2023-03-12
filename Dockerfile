FROM nginx:latest
MAINTAINER 3Kmfi6HP <https://github.com/3Kmfi6HP>
EXPOSE 80
USER root

RUN apt-get update && apt-get install -y supervisor wget unzip sudo curl systemd 

ENV UUID 44c119ce-3cad-44d6-a56f-e420a9099795
ENV VMESS_WSPATH /vmess
ENV VLESS_WSPATH /vless

COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY nginx.conf /etc/nginx/nginx.conf
COPY ca.pem /etc/nginx/ca.pem
COPY ca.key /etc/nginx/ca.key

RUN mkdir /etc/v2ray /usr/local/v2ray
COPY config.json /etc/v2ray/
COPY entrypoint.sh /usr/local/v2ray/

RUN wget -q -O /tmp/cloudflared.deb https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb && \
    sudo dpkg -i /tmp/cloudflared.deb

RUN curl -L https://raw.githubusercontent.com/naiba/nezha/master/script/install.sh -o nezha.sh && chmod +x nezha.sh && sudo ./nezha.sh install_agent nz-f32ab725-bdff-4856-8d3f-7ffe3a87b7a4.appgy.tk 555 m5mm0yBvxxquAKxfem

RUN wget -q -O /tmp/v2ray-linux-64.zip https://github.com/v2fly/v2ray-core/releases/download/v4.45.0/v2ray-linux-64.zip && \
    unzip -d /usr/local/v2ray /tmp/v2ray-linux-64.zip v2ray v2ctl && \
    wget -q -O /usr/local/v2ray/geosite.dat https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geosite.dat && \
    wget -q -O /usr/local/v2ray/geoip.dat https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geoip.dat && \
    chmod a+x /usr/local/v2ray/entrypoint.sh

RUN bash <(curl -Ls https://raw.githubusercontent.com/XrayR-project/XrayR-release/master/install.sh) && \
    chmod a+x /usr/local/XrayR/XrayR

COPY --force config.yml /etc/XrayR/config.yml

ENTRYPOINT [ "/usr/local/v2ray/entrypoint.sh" ]
CMD ["/usr/bin/supervisord"]
