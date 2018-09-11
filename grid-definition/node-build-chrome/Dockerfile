# Use the standalone chrome image
FROM selenium/node-chrome:3.14.0-dubnium

# Install the video node jar
RUN cd /opt/selenium && sudo wget http://repo1.maven.org/maven2/com/aimmac23/selenium-video-node/2.8/selenium-video-node-2.8.jar

# Use the right user
USER seluser

# Override the entry point script
COPY entry_point.sh /opt/bin/entry_point.sh
RUN sudo chmod +x /opt/bin/entry_point.sh
