FROM rocker/shiny:4.2.3

# Delete the example application, copy dependency lock file and install R dependencies
RUN rm -rf /srv/shiny-server/*
COPY /install/packages_installation.R /install/renv.lock /srv/shiny-server/
ARG MAKE="make -j2"
WORKDIR /srv/shiny-server/
RUN R -f packages_installation.R

# Copy the rest of the application. Doing it in this order allows changes to the app folder
# without invoking a package rebuild
COPY /app/app.R ./


# Run as user shiny instead of root and expose the port
# USER shiny
EXPOSE 3838

# Build app_config.R file and start application
CMD ["/init"]
