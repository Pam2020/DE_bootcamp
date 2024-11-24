## Week 1: Dimensional Data Modeling: Hands-on

In this week, we will be building a cumulative table design. When building master data, we need to have the complete history, store all dimensions. 

Core components of cumulative table design:
- 2 Dataframes (yesterday and today)
- FULL OUTER JOIN the two dataframes
- COALESCE ids and other unchanging dimensions
- Compute cumulative metrics (eg. days since x)
- Combine arrays and changing values

#### 1. Install Docker desktop from the website. 
   - https://www.docker.com/

#### 2. **Clone the repository**

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
   
#### 🐳 **3: Run Postgres in Docker**

- Install Docker Desktop from **[here](https://www.docker.com/products/docker-desktop/)**.
- Copy **`example.env`** to **`.env`**:
    
    ```bash
    cp example.env .env
    ```

- Start the Docker Compose container:
    - If you're on Mac:
        
        ```bash
        make up
        ```
        
    - If you're on Windows:
        
        ```bash
        docker compose up -d
        ```
      
- A folder named **`postgres-data`** will be created in the root of the repo. The data backing your Postgres instance will be saved here.
- You can check that your Docker Compose stack is running by either:
    - Going into Docker Desktop: you should see an entry there with a drop-down for each of the containers running in your Docker Compose stack.
    - Running **`docker ps -a`** and looking for the containers with the name **`postgres`**.
- When you're finished with your Postgres instance, you can stop the Docker Compose containers with:
    
    ```bash
    make down
    ```
    
    Or if you're on Windows:
    
    ```bash
    docker compose down -v
    ```

  #### 4. **Connect to Postgres in Database Client**

  - Some options for interacting with your Postgres instance:
    - DataGrip - JetBrains; 30-day free trial or paid version.
    - VSCode built-in extension (there are a few of these).
    - PGAdmin.
    - Postbird.
- Using your client of choice, follow the instructions to establish a new PostgreSQL connection.
    - The default username is **`postgres`** and corresponds to **`$POSTGRES_USER`** in your **`.env`**.
    - The default password is **`postgres`** and corresponds to **`$POSTGRES_PASSWORD`** in your **`.env`**.
    - The default database is **`postgres`** and corresponds to **`$POSTGRES_DB`** in your **`.env`**.
    - The default host is **`localhost`** or **`0.0.0.0`.** This is the IP address of the Docker container running the PostgreSQL instance.
    - The default port for Postgres is **`5432` .** This corresponds to the **`$CONTAINER_PORT`** variable in the **`.env`** file.
    
    &rarr; :bulb: You can edit these values by modifying the corresponding values in **`.env`**.
    
- If the test connection is successful, click "Finish" or "Save" to save the connection. You should now be able to use the database client to manage your PostgreSQL database locally.

#### 5. Cumulative table design and historical analysis
Find all the queries used to build the cumulative table creation and analysis in the CumulativeTableDesign.sql script.
