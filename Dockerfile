FROM node:6-slim

ADD ./ /home/michelek/publisher
RUN npm --silent --production install
CMD ["node", "/home/michelek/publisher/master.js"]
