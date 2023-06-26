# LASUR-R-SHINY
Repository for a template R Shiny web application.


## Introduction

The purpose of this repository is to provide a comprehensive guide on how to host a R Shiny web application with Docker. 

Docker is a powerful tool that leverages containerization technology to streamline the deployment process of web applications. By following the steps outlined in this guide, you will gain a better understanding of how to containerize your R Shiny web application and deploy it to a production environment with ease.

## Repository stucture


**Core application files**

These folders contain the application core files. They can be modified to change the application behavior / content. 

📁 app - *folder containing the R application*

📁 data - *folder containing the data*

📁 install - *folder containing the installation files*



**Hosting, access and deployment files**

These folders contain the hosting files. These files should not be changed. 

📁 .github - *folder containing the continuous deployment scripts*

📁 cert - *folder containing certificates for the web interface*

📁 doc - *folder containing the documentation images*

📁 tequila - *folder containing the user access files (via tequila)*






## Development environment

The development environment utilizes Docker to run the application in the same way it will run in production (on the internet). If it works locally with Docker, it will also work in production with Docker.

### Prerequisite

- Install Docker on your machine as explained on the [ENAC-IT4R web page](https://www.notion.so/Docker-quick-setup-278abe4712024abaaeea77e49a4c5b9f).

    Make sure to set the core.eol configuration option to lf to ensure consistent line endings. This is needed to avoid errors when running the application in Docker.

    ```bash
    git config --global core.eol lf
    ```


- Install Git as explained on the [ENAC-IT4R web page](https://www.notion.so/Install-Git-0a608fb1909f471284c189cf172c9016).

These are the only applications needed. R and Shiny are installed inside the Docker container.

### How to run the application locally ?

1. Open a command line window (PowerShell for Windows).
1. Navigate to the cloned or unzipped folder:
    
    ```bash
    cd <your_path>/LASUR-R-SHINY
    ```


1. Clone the repository:
    
    ```bash
    git clone https://github.com/EPFL-ENAC/LASUR-R-SHINY.git
    
    ```

1. Navigate to the cloned folder:
    
    ```bash
    cd LASUR-R-SHINY
    ```

Option 1 : Local run with tequila authentication : 


5. Run the command to generate the certificates:
    
    ```bash
    make generate-selfsigned-cert-win
    ``` 
    This creates 2 files in the `cert` folder: `certificate.crt` and `certificate.key`. This is needed to run the application locally with Docker and tequila authentication.

1. Run the following command to create the Docker image:
    
    ```bash
    make run
    ```
   The application should now be running in your web browser at [http://localhost](http://localhost/). Access to the application is restricted by tequila. You may see a warning about invalid certificates, that can be safely ignored.

Option 2 : Local run without tequila authentication :

5. Run the following command to create the Docker image:
    
    ```bash
    docker build -t poc_lasur_r_shiny .
    ```
   The application has been installed locally on your computer.

1. To load the data and start the app, run the following command:

- On Windows:
    
    ```bash
    docker run -p 3838:3838 -v ${pwd}/data/EPFL_vague1_extrait.csv:/srv/shiny-server/data.csv poc_lasur_r_shiny:latest
    
    ```
    
- On MAC/Linux:
    
    ```
    docker run -p 3838:3838 -v $(pwd)/data/EPFL_vague1_extrait.csv:/srv/shiny-server/data.csv poc_lasur_r_shiny:latest
    
    ```


    Where `EPFL_vague1_extrait.csv` is the name of the data file.

    The application should now be running in your web browser at [http://localhost:3838/](http://localhost:3838/).



    


### How to add changes to the code or to the source data ?

Here are the process to follow to contribute to this project :

![contribute](docs/statics/contributing_process.png)


1. Make sure you are on the `feature_x` branch:
    
    ```bash
    git checkout feature_x
    ```

    if you would like to work in a new branch :
        
    ```bash
    git checkout -b feature_x
    ```

    

2. Make changes to the code or to the data.

    > Note that if the data file name as changed, the `docker-compose.yml` file must be updated accordingly.

3. Test the application locally as explained in the previous section.

    ```bash
    make run
    ```

    The application should now be running in your web browser at [http://localhost/](http://localhost). You may see a warning about invalid certificates, that can be safely ignored.


1. Add the files to the staging area:
    
    ```bash
    git add .
    ```


4. Commit your changes:
    
    ```bash
    git commit -am "Add some feature"
    ```

5. Push to the branch:
    
    ```bash
    git push origin feature_x
    ```

6. Create a pull request to the dev branch.

7. Once the pull request is approved, merge it to the dev branch.




## Test and production environment

There are two web interfaces for this application : 

* [panel-lemanique.epfl.ch](https://panel-lemanique.epfl.ch/) : the production interface based on the _main_ branch of this repository
* [panel-lemanique-test.epfl.ch](https://panel-lemanique-test.epfl.ch/) : the test interface based on the _dev_ branch of this repository


Access to these interfaces is restricted by tequila. 

* Users outside EPFL can create a guest profile on [guests.epfl.ch](https://guests.epfl.ch)
* New profile (EPFL and no-EPFL users) can be granted accreditation for the `panel-lemanique-users` group through [groups.epfl.ch](https://groups.epfl.ch) by the administrators.












