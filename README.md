# Data Engineering bootcamp

Practicing DE projects from Zach Wilson's DE bootcamp!

### Week 1: Dimensional Data Modeling: Hands-on

In this week, we will be building a cumulative table design. When building master data, we need to have the complete history, store all dimensions. 

Core components of cumulative table design:
- 2 Dataframes (yesterday and today)
- FULL OUTER JOIN the two dataframes
- COALESCE ids and other unchanging dimensions
- Compute cumulative metrics (eg. days since x)
- Combine arrays and changing values

Hands-on:
1. Install Docker desktop from the website. 
   - https://www.docker.com/
2. Clone the repository.

## 1️⃣ **Clone the repository**

- Clone the repo using the SSH link. This will create a new folder in the current directory on your local machine.
    
    ```bash
    git clone git@github.com:DataExpert-io/data-engineer-handbook.git
    ```
    
    > ℹ️ To securely interact with GitHub repositories, it is recommended to use SSH keys. Follow the instructions provided **[here](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/adding-a-new-ssh-key-to-your-github-account)** to set up SSH keys on GitHub. Set up an SSH key on your computer and upload it into Github. 
    > 

- Navigate into the cloned repo using the command line:
    
    ```bash
    cd data-engineer-handbook/bootcamp/materials/1-dimensional-data-modeling
    ```


4. Run a PostgreSQL instance on the docker desktop.
   - Pull the PostgreSQL Image: bf{docker pull postgres}
   - Run a PostgreSQL container: docker run --name my-postgres -e POSTGRES_USER=admin -e POSTGRES_PASSWORD=adminpassword -e POSTGRES_DB=mydatabase -p 5432:5432 -d postgres
   - Verify the container: docker ps
   - Access PostgreSQL instance through a psql CLI or a database client tool (eg. DBeaver, pdadmin):
      - Host: localhost
      - Port: 5432
      - Username: admin
      - Password: adminpassword
      - Database: mydatabase
   
   - Stop the container: docker stop my-postgres
   - Remove the container: docker rm my-postgres
      


