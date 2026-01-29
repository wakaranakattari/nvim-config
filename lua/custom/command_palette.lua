local M = {}

local user_commands = {}
local user_projects = {}

local function get_project_dir()
  local dir = vim.fn.input("Project directory: ", vim.fn.getcwd())
  if dir == "" then
    return vim.fn.getcwd()
  end
  if vim.fn.isdirectory(dir) == 0 then
    vim.fn.mkdir(dir, "p")
  end
  return dir
end

local function run_command(cmd)
  vim.cmd("tabnew")
  vim.cmd("term " .. cmd)
end

local function open_in_nvim(dir, project_name)
  local full_path = dir .. "/" .. project_name
  if vim.fn.isdirectory(full_path) == 1 then
    vim.cmd("cd " .. full_path)
    vim.cmd("e .")
    vim.notify("Opened project: " .. project_name, vim.log.levels.INFO)
  else
    vim.notify("Directory doesn't exist: " .. full_path, vim.log.levels.ERROR)
  end
end

local function add_custom_command(category, subcategory, name, command)
  user_commands[category] = user_commands[category] or {}
  user_commands[category][subcategory] = user_commands[category][subcategory] or {}
  user_commands[category][subcategory][name] = command
end

local function add_custom_project(name, config_func)
  user_projects[name] = config_func
end

local commands_db = {
  Frontend = {
    Vite = {
      ["Dev Server"] = "npm run dev",
      ["Build"] = "npm run build",
      ["Preview"] = "npm run preview",
      ["Install"] = "npm install",
      ["Test"] = "npm run test",
      ["Lint"] = "npm run lint",
      ["Format"] = "npm run format",
    },
    Nextjs = {
      ["Dev Server"] = "npm run dev",
      ["Build"] = "npm run build",
      ["Start"] = "npm run start",
      ["Lint"] = "npm run lint",
      ["Export"] = "npm run export",
      ["Analyze"] = "npm run analyze",
    },
    Nuxt = {
      ["Dev"] = "npm run dev",
      ["Build"] = "npm run build",
      ["Generate"] = "npm run generate",
      ["Preview"] = "npm run preview",
    },
    Astro = {
      ["Dev"] = "npm run dev",
      ["Build"] = "npm run build",
      ["Preview"] = "npm run preview",
      ["Sync"] = "npm run sync",
    },
    SvelteKit = {
      ["Dev"] = "npm run dev",
      ["Build"] = "npm run build",
      ["Preview"] = "npm run preview",
      ["Check"] = "npm run check",
    },
    Remix = {
      ["Dev"] = "npm run dev",
      ["Build"] = "npm run build",
      ["Start"] = "npm run start",
    },
    Gatsby = {
      ["Develop"] = "npm run develop",
      ["Build"] = "npm run build",
      ["Serve"] = "npm run serve",
    },
    Angular = {
      ["Serve"] = "ng serve",
      ["Build"] = "ng build",
      ["Test"] = "ng test",
      ["Lint"] = "ng lint",
    },
    Vue = {
      ["Serve"] = "npm run serve",
      ["Build"] = "npm run build",
      ["Lint"] = "npm run lint",
    },
    React = {
      ["Start"] = "npm start",
      ["Build"] = "npm run build",
      ["Test"] = "npm test",
      ["Eject"] = "npm run eject",
    },
  },
  Backend = {
    Node = {
      ["Start"] = "npm start",
      ["Dev"] = "npm run dev",
      ["Debug"] = "npm run debug",
      ["Test"] = "npm test",
      ["Test Watch"] = "npm run test:watch",
    },
    Express = {
      ["Start"] = "npm start",
      ["Dev"] = "nodemon server.js",
      ["Debug"] = "node --inspect server.js",
    },
    NestJS = {
      ["Start"] = "npm run start",
      ["Start Dev"] = "npm run start:dev",
      ["Start Debug"] = "npm run start:debug",
      ["Build"] = "npm run build",
    },
    Fastify = {
      ["Start"] = "npm start",
      ["Dev"] = "npm run dev",
      ["Test"] = "npm test",
    },
    Django = {
      ["Runserver"] = "python manage.py runserver",
      ["Migrate"] = "python manage.py migrate",
      ["Makemigrations"] = "python manage.py makemigrations",
      ["Shell"] = "python manage.py shell",
      ["Test"] = "python manage.py test",
    },
    Flask = {
      ["Run"] = "flask run",
      ["Shell"] = "flask shell",
      ["Routes"] = "flask routes",
    },
    Rails = {
      ["Server"] = "rails server",
      ["Console"] = "rails console",
      ["DB Migrate"] = "rails db:migrate",
      ["Test"] = "rails test",
    },
    Laravel = {
      ["Serve"] = "php artisan serve",
      ["Tinker"] = "php artisan tinker",
      ["Migrate"] = "php artisan migrate",
      ["Test"] = "php artisan test",
    },
    Phoenix = {
      ["Server"] = "mix phx.server",
      ["Console"] = "iex -S mix",
      ["Test"] = "mix test",
    },
    Spring = {
      ["BootRun"] = "./gradlew bootRun",
      ["Build"] = "./gradlew build",
      ["Test"] = "./gradlew test",
    },
  },
  Mobile = {
    ReactNative = {
      ["Android"] = "npm run android",
      ["IOS"] = "npm run ios",
      ["Start"] = "npm start",
      ["Build Android"] = "cd android && ./gradlew assembleRelease",
    },
    Flutter = {
      ["Run"] = "flutter run",
      ["Build APK"] = "flutter build apk",
      ["Build IOS"] = "flutter build ios",
      ["Test"] = "flutter test",
    },
    Ionic = {
      ["Serve"] = "ionic serve",
      ["Build"] = "ionic build",
      ["Capacitor Run"] = "ionic capacitor run",
    },
    Expo = {
      ["Start"] = "expo start",
      ["Android"] = "expo start --android",
      ["IOS"] = "expo start --ios",
      ["Build Android"] = "expo build:android",
    },
  },
  Desktop = {
    Electron = {
      ["Start"] = "npm start",
      ["Build"] = "npm run build",
      ["Package"] = "npm run package",
      ["Make"] = "npm run make",
    },
    Tauri = {
      ["Dev"] = "npm run tauri dev",
      ["Build"] = "npm run tauri build",
    },
    Qt = {
      ["CMake Build"] = "cmake --build .",
      ["QMake"] = "qmake && make",
    },
    GTK = {
      ["Meson Build"] = "meson build && ninja -C build",
    },
  },
  Database = {
    PostgreSQL = {
      ["Start"] = "sudo systemctl start postgresql",
      ["Stop"] = "sudo systemctl stop postgresql",
      ["Restart"] = "sudo systemctl restart postgresql",
      ["Status"] = "sudo systemctl status postgresql",
      ["Psql"] = "psql -U postgres",
      ["Backup"] = "pg_dump -U postgres database_name > backup.sql",
    },
    MySQL = {
      ["Start"] = "sudo systemctl start mysql",
      ["Stop"] = "sudo systemctl stop mysql",
      ["MySQL"] = "mysql -u root -p",
      ["Dump"] = "mysqldump -u root -p database_name > backup.sql",
    },
    MongoDB = {
      ["Start"] = "sudo systemctl start mongod",
      ["Stop"] = "sudo systemctl stop mongod",
      ["Mongo Shell"] = "mongosh",
      ["Dump"] = "mongodump --db database_name",
    },
    Redis = {
      ["Start"] = "sudo systemctl start redis-server",
      ["Stop"] = "sudo systemctl stop redis-server",
      ["CLI"] = "redis-cli",
      ["Monitor"] = "redis-cli monitor",
    },
    SQLite = {
      ["Shell"] = "sqlite3 database.db",
    },
    Prisma = {
      ["Generate"] = "npx prisma generate",
      ["Migrate Dev"] = "npx prisma migrate dev",
      ["Migrate Deploy"] = "npx prisma migrate deploy",
      ["Studio"] = "npx prisma studio",
    },
    Drizzle = {
      ["Generate"] = "npm run db:generate",
      ["Migrate"] = "npm run db:migrate",
      ["Push"] = "npm run db:push",
      ["Studio"] = "npm run db:studio",
    },
  },
  DevOps = {
    Docker = {
      ["Build"] = "docker build -t myapp .",
      ["Run"] = "docker run -p 3000:3000 myapp",
      ["Run Detached"] = "docker run -d -p 3000:3000 myapp",
      ["PS"] = "docker ps",
      ["PS All"] = "docker ps -a",
      ["Images"] = "docker images",
      ["Logs"] = "docker logs container_id",
      ["Exec"] = "docker exec -it container_id sh",
      ["Stop"] = "docker stop container_id",
      ["Remove"] = "docker rm container_id",
      ["Prune"] = "docker system prune -a",
      ["Compose Up"] = "docker-compose up",
      ["Compose Down"] = "docker-compose down",
      ["Compose Logs"] = "docker-compose logs -f",
      ["Compose Build"] = "docker-compose build",
    },
    Kubernetes = {
      ["Get Pods"] = "kubectl get pods",
      ["Get Services"] = "kubectl get services",
      ["Get Deployments"] = "kubectl get deployments",
      ["Apply"] = "kubectl apply -f deployment.yaml",
      ["Delete"] = "kubectl delete -f deployment.yaml",
      ["Describe Pod"] = "kubectl describe pod pod_name",
      ["Logs"] = "kubectl logs pod_name",
      ["Exec"] = "kubectl exec -it pod_name -- sh",
    },
    Terraform = {
      ["Init"] = "terraform init",
      ["Plan"] = "terraform plan",
      ["Apply"] = "terraform apply",
      ["Destroy"] = "terraform destroy",
      ["Validate"] = "terraform validate",
      ["Fmt"] = "terraform fmt",
    },
    Ansible = {
      ["Playbook"] = "ansible-playbook playbook.yml",
      ["Ping"] = "ansible all -m ping",
      ["Adhoc"] = "ansible all -a 'uptime'",
    },
    AWS = {
      ["S3 List"] = "aws s3 ls",
      ["EC2 List"] = "aws ec2 describe-instances",
      ["Lambda List"] = "aws lambda list-functions",
      ["CloudFormation"] = "aws cloudformation describe-stacks",
    },
    GCP = {
      ["Projects List"] = "gcloud projects list",
      ["Instances List"] = "gcloud compute instances list",
      ["Buckets List"] = "gsutil ls",
    },
    Azure = {
      ["List VMs"] = "az vm list",
      ["List Resources"] = "az resource list",
      ["List Groups"] = "az group list",
    },
  },
  Testing = {
    Jest = {
      ["Test"] = "npm test",
      ["Test Watch"] = "npm run test:watch",
      ["Coverage"] = "npm run test:coverage",
    },
    Vitest = {
      ["Test"] = "npm run test",
      ["Test UI"] = "npm run test:ui",
      ["Coverage"] = "npm run test:coverage",
    },
    Cypress = {
      ["Open"] = "npm run cypress:open",
      ["Run"] = "npm run cypress:run",
    },
    Playwright = {
      ["Test"] = "npm run test",
      ["Test UI"] = "npm run test:ui",
      ["Codegen"] = "npx playwright codegen",
    },
    Selenium = {
      ["Run Tests"] = "python -m pytest tests/",
    },
    Puppeteer = {
      ["Run Tests"] = "npm run test",
    },
  },
  Tools = {
    Git = {
      ["Status"] = "git status",
      ["Add All"] = "git add .",
      ["Commit"] = "git commit -m 'update'",
      ["Push"] = "git push",
      ["Pull"] = "git pull",
      ["Fetch"] = "git fetch",
      ["Branch"] = "git branch",
      ["Checkout"] = "git checkout branch_name",
      ["Merge"] = "git merge branch_name",
      ["Stash"] = "git stash",
      ["Stash Pop"] = "git stash pop",
      ["Log"] = "git log --oneline",
      ["Diff"] = "git diff",
      ["Reset Hard"] = "git reset --hard HEAD",
      ["Clean"] = "git clean -fd",
      ["Clone"] = "git clone repository_url",
      ["Init"] = "git init",
      ["Remote Add"] = "git remote add origin repository_url",
      ["Rebase"] = "git rebase branch_name",
    },
    NPM = {
      ["Install"] = "npm install",
      ["Install Global"] = "npm install -g package_name",
      ["Update"] = "npm update",
      ["Audit"] = "npm audit",
      ["Audit Fix"] = "npm audit fix",
      ["List Global"] = "npm list -g --depth=0",
      ["Outdated"] = "npm outdated",
      ["Run Script"] = "npm run script_name",
      ["Init"] = "npm init",
      ["Publish"] = "npm publish",
    },
    Yarn = {
      ["Install"] = "yarn install",
      ["Add"] = "yarn add package_name",
      ["Upgrade"] = "yarn upgrade",
      ["Build"] = "yarn build",
      ["Dev"] = "yarn dev",
    },
    PNPM = {
      ["Install"] = "pnpm install",
      ["Add"] = "pnpm add package_name",
      ["Build"] = "pnpm build",
      ["Dev"] = "pnpm dev",
    },
    Bun = {
      ["Install"] = "bun install",
      ["Add"] = "bun add package_name",
      ["Run"] = "bun run script_name",
    },
    Make = {
      ["Make"] = "make",
      ["Clean"] = "make clean",
      ["Test"] = "make test",
      ["Install"] = "make install",
    },
    CMake = {
      ["Configure"] = "cmake .",
      ["Build"] = "cmake --build .",
      ["Clean"] = "cmake --build . --target clean",
    },
    Gradle = {
      ["Build"] = "./gradlew build",
      ["Test"] = "./gradlew test",
      ["Clean"] = "./gradlew clean",
      ["Run"] = "./gradlew run",
    },
    Maven = {
      ["Compile"] = "mvn compile",
      ["Test"] = "mvn test",
      ["Package"] = "mvn package",
      ["Clean"] = "mvn clean",
    },
  },
  System = {
    Ubuntu = {
      ["Update"] = "sudo apt update && sudo apt upgrade",
      ["Install"] = "sudo apt install package_name",
      ["Remove"] = "sudo apt remove package_name",
      ["Autoremove"] = "sudo apt autoremove",
      ["Clean"] = "sudo apt autoclean",
      ["Search"] = "apt search package_name",
    },
    Arch = {
      ["Update"] = "sudo pacman -Syu",
      ["Install"] = "sudo pacman -S package_name",
      ["Remove"] = "sudo pacman -R package_name",
      ["Search"] = "pacman -Ss package_name",
    },
    Fedora = {
      ["Update"] = "sudo dnf update",
      ["Install"] = "sudo dnf install package_name",
      ["Remove"] = "sudo dnf remove package_name",
    },
    Process = {
      ["Top"] = "top",
      ["Htop"] = "htop",
      ["PS"] = "ps aux",
      ["Kill"] = "kill -9 pid",
      ["Pkill"] = "pkill process_name",
    },
    Disk = {
      ["Usage"] = "df -h",
      ["Free"] = "free -h",
      ["Du"] = "du -sh *",
      ["Find Large"] = "find . -type f -size +100M",
    },
    Network = {
      ["IP"] = "ip addr show",
      ["Ping"] = "ping google.com",
      ["Curl"] = "curl ifconfig.me",
      ["Wget"] = "wget url",
      ["Netstat"] = "netstat -tulpn",
      ["SSH"] = "ssh user@host",
      ["SCP"] = "scp file user@host:/path",
    },
    Service = {
      ["List"] = "systemctl list-units --type=service",
      ["Start"] = "sudo systemctl start service_name",
      ["Stop"] = "sudo systemctl stop service_name",
      ["Restart"] = "sudo systemctl restart service_name",
      ["Status"] = "sudo systemctl status service_name",
      ["Enable"] = "sudo systemctl enable service_name",
      ["Disable"] = "sudo systemctl disable service_name",
    },
    Logs = {
      ["Journal"] = "journalctl -f",
      ["Syslog"] = "tail -f /var/log/syslog",
      ["Auth"] = "tail -f /var/log/auth.log",
      ["Kernel"] = "dmesg -w",
    },
  },
  Languages = {
    Rust = {
      ["Run"] = "cargo run",
      ["Build"] = "cargo build",
      ["Build Release"] = "cargo build --release",
      ["Test"] = "cargo test",
      ["Check"] = "cargo check",
      ["Clippy"] = "cargo clippy",
      ["Fmt"] = "cargo fmt",
      ["Doc"] = "cargo doc --open",
      ["Clean"] = "cargo clean",
      ["Update"] = "cargo update",
      ["Add"] = "cargo add crate_name",
    },
    Go = {
      ["Run"] = "go run .",
      ["Build"] = "go build",
      ["Test"] = "go test ./...",
      ["Fmt"] = "go fmt ./...",
      ["Mod Tidy"] = "go mod tidy",
      ["Mod Download"] = "go mod download",
      ["Install"] = "go install",
      ["Get"] = "go get package_url",
    },
    Python = {
      ["Run"] = "python main.py",
      ["Run3"] = "python3 main.py",
      ["Install"] = "pip install -r requirements.txt",
      ["Freeze"] = "pip freeze > requirements.txt",
      ["Virtualenv"] = "python -m venv venv",
      ["Activate"] = "source venv/bin/activate",
      ["Deactivate"] = "deactivate",
      ["Pytest"] = "pytest",
      ["Black"] = "black .",
      ["Flake8"] = "flake8 .",
      ["Mypy"] = "mypy .",
    },
    Java = {
      ["Compile"] = "javac Main.java",
      ["Run"] = "java Main",
      ["Jar"] = "jar -cvf app.jar *.class",
    },
    Kotlin = {
      ["Compile"] = "kotlinc main.kt -include-runtime -d main.jar",
      ["Run"] = "java -jar main.jar",
    },
    C = {
      ["GCC Compile"] = "gcc -o program program.c",
      ["Run"] = "./program",
    },
    CPP = {
      ["G++ Compile"] = "g++ -o program program.cpp",
      ["Run"] = "./program",
    },
    CSharp = {
      ["Dotnet Run"] = "dotnet run",
      ["Dotnet Build"] = "dotnet build",
      ["Dotnet Test"] = "dotnet test",
    },
    PHP = {
      ["Serve"] = "php -S localhost:8000",
      ["Test"] = "phpunit",
      ["Composer Install"] = "composer install",
      ["Composer Update"] = "composer update",
    },
    Ruby = {
      ["Run"] = "ruby script.rb",
      ["Bundle Install"] = "bundle install",
      ["Rake"] = "rake task_name",
    },
    Swift = {
      ["Build"] = "swift build",
      ["Run"] = "swift run",
      ["Test"] = "swift test",
    },
    Haskell = {
      ["Run"] = "runhaskell program.hs",
      ["GHCI"] = "ghci",
    },
    Elixir = {
      ["Mix Run"] = "mix run",
      ["Mix Test"] = "mix test",
      ["IEX"] = "iex -S mix",
    },
    Clojure = {
      ["Lein Run"] = "lein run",
      ["Lein Test"] = "lein test",
      ["REPL"] = "lein repl",
    },
    Lua = {
      ["Run"] = "lua script.lua",
      ["Luarocks Install"] = "luarocks install package_name",
    },
    Zig = {
      ["Build"] = "zig build",
      ["Run"] = "zig build run",
      ["Test"] = "zig build test",
    },
    OCaml = {
      ["Build"] = "dune build",
      ["Run"] = "dune exec program_name",
    },
    R = {
      ["Run"] = "Rscript script.R",
    },
  },
  Monitoring = {
    Nginx = {
      ["Test Config"] = "nginx -t",
      ["Reload"] = "nginx -s reload",
      ["Stop"] = "nginx -s stop",
      ["Start"] = "sudo systemctl start nginx",
      ["Status"] = "sudo systemctl status nginx",
    },
    Apache = {
      ["Config Test"] = "apache2ctl configtest",
      ["Restart"] = "sudo systemctl restart apache2",
      ["Status"] = "sudo systemctl status apache2",
    },
    PM2 = {
      ["Start"] = "pm2 start ecosystem.config.js",
      ["Stop"] = "pm2 stop all",
      ["Restart"] = "pm2 restart all",
      ["Delete"] = "pm2 delete all",
      ["Logs"] = "pm2 logs",
      ["Monitor"] = "pm2 monit",
      ["List"] = "pm2 list",
      ["Save"] = "pm2 save",
      ["Startup"] = "pm2 startup",
    },
    Supervisor = {
      ["Start"] = "sudo supervisorctl start program_name",
      ["Stop"] = "sudo supervisorctl stop program_name",
      ["Restart"] = "sudo supervisorctl restart program_name",
      ["Status"] = "sudo supervisorctl status",
      ["Reload"] = "sudo supervisorctl reload",
    },
  },
}

local projects_db = {
  Vite = function()
    local dir = get_project_dir()
    local project_name = vim.fn.input("Project name: ")
    if project_name == "" then
      project_name = "vite-app"
    end

    local templates = {
      ["Vue + TypeScript"] = "vue-ts",
      ["Vue + JavaScript"] = "vue",
      ["React + TypeScript"] = "react-ts",
      ["React + JavaScript"] = "react",
      ["Svelte + TypeScript"] = "svelte-ts",
      ["Svelte + JavaScript"] = "svelte",
      ["Vanilla + TypeScript"] = "vanilla-ts",
      ["Vanilla + JavaScript"] = "vanilla",
      ["Preact + TypeScript"] = "preact-ts",
      ["Preact + JavaScript"] = "preact",
      ["Lit + TypeScript"] = "lit-ts",
      ["Lit + JavaScript"] = "lit",
      ["Qwik + TypeScript"] = "qwik-ts",
      ["Qwik + JavaScript"] = "qwik",
      ["Solid + TypeScript"] = "solid-ts",
      ["Solid + JavaScript"] = "solid",
    }

    vim.ui.select(vim.tbl_keys(templates), {
      prompt = "Select template:",
    }, function(template_name)
      if not template_name then
        return
      end

      local template = templates[template_name]
      local full_cmd = "cd " .. dir .. " && npm create vite@latest " .. project_name .. " -- --template " .. template

      vim.ui.select({ "Yes", "No" }, {
        prompt = "Open in Neovim after creation?",
      }, function(open_nvim)
        if not open_nvim then
          return
        end

        run_command(full_cmd)

        if open_nvim == "Yes" then
          vim.defer_fn(function()
            open_in_nvim(dir, project_name)
          end, 5000)
        end
      end)
    end)
  end,
  ["Next.js"] = function()
    local dir = get_project_dir()
    local project_name = vim.fn.input("Project name: ")
    if project_name == "" then
      project_name = "next-app"
    end

    local variants = {
      ["TypeScript + Tailwind + App Router"] = " --typescript --tailwind --app",
      ["TypeScript + App Router"] = " --typescript --app",
      ["JavaScript + Tailwind + App Router"] = " --tailwind --app",
      ["JavaScript + App Router"] = " --app",
      ["TypeScript + Pages Router"] = " --typescript",
      ["JavaScript + Pages Router"] = "",
      ["TypeScript + Tailwind + Pages"] = " --typescript --tailwind",
      ["JavaScript + Tailwind + Pages"] = " --tailwind",
    }

    vim.ui.select(vim.tbl_keys(variants), {
      prompt = "Select variant:",
    }, function(variant_name)
      if not variant_name then
        return
      end

      local flags = variants[variant_name]
      local cmd = "cd " .. dir .. " && npx create-next-app@latest " .. project_name .. flags

      vim.ui.select({ "Yes", "No" }, {
        prompt = "Open in Neovim after creation?",
      }, function(open_nvim)
        if not open_nvim then
          return
        end

        run_command(cmd)

        if open_nvim == "Yes" then
          vim.defer_fn(function()
            open_in_nvim(dir, project_name)
          end, 5000)
        end
      end)
    end)
  end,
  Nuxt = function()
    local dir = get_project_dir()
    local project_name = vim.fn.input("Project name: ")
    if project_name == "" then
      project_name = "nuxt-app"
    end

    vim.ui.select({ "TypeScript", "JavaScript" }, {
      prompt = "Select variant:",
    }, function(variant)
      if not variant then
        return
      end

      local cmd = "cd " .. dir .. " && npx nuxi@latest init " .. project_name
      if variant == "TypeScript" then
        cmd = cmd .. " --ts"
      end

      vim.ui.select({ "None", "Tailwind", "Element Plus", "Naive UI", "Ant Design" }, {
        prompt = "UI Framework:",
      }, function(ui)
        if not ui then
          return
        end

        run_command(cmd)

        if ui == "Tailwind" then
          vim.cmd("sleep 3000m")
          run_command("cd " .. project_name .. " && npm install -D @nuxtjs/tailwindcss")
        end

        vim.ui.select({ "Yes", "No" }, {
          prompt = "Open in Neovim?",
        }, function(open_nvim)
          if open_nvim == "Yes" then
            vim.defer_fn(function()
              open_in_nvim(dir, project_name)
            end, 5000)
          end
        end)
      end)
    end)
  end,
  Astro = function()
    local dir = get_project_dir()
    local project_name = vim.fn.input("Project name: ")
    if project_name == "" then
      project_name = "astro-site"
    end

    local templates = {
      "blog",
      "docs",
      "portfolio",
      "minimal",
      "basics",
      "framework-multiple",
      "framework-react",
      "framework-vue",
      "framework-svelte",
      "framework-preact",
    }

    vim.ui.select(templates, {
      prompt = "Select template:",
    }, function(template)
      if not template then
        return
      end

      vim.ui.select({ "TypeScript", "JavaScript" }, {
        prompt = "Select variant:",
      }, function(variant)
        if not variant then
          return
        end

        local cmd = "cd " .. dir .. " && npm create astro@latest " .. project_name .. " -- --template " .. template
        if variant == "TypeScript" then
          cmd = cmd .. " --typescript"
        end

        vim.ui.select({ "Yes", "No" }, {
          prompt = "Open in Neovim after creation?",
        }, function(open_nvim)
          if not open_nvim then
            return
          end

          run_command(cmd)

          if open_nvim == "Yes" then
            vim.defer_fn(function()
              open_in_nvim(dir, project_name)
            end, 5000)
          end
        end)
      end)
    end)
  end,
  Tauri = function()
    local dir = get_project_dir()
    local project_name = vim.fn.input("Project name: ")
    if project_name == "" then
      project_name = "tauri-app"
    end

    local frontends = { "Vanilla", "Vue", "React", "Svelte", "Solid", "Preact", "Angular" }

    vim.ui.select(frontends, {
      prompt = "Select frontend:",
    }, function(frontend)
      if not frontend then
        return
      end

      local cmd = "cd "
        .. dir
        .. " && npm create tauri-app@latest "
        .. project_name
        .. " -- --frontend "
        .. string.lower(frontend)

      vim.ui.select({ "Yes", "No" }, {
        prompt = "Open in Neovim after creation?",
      }, function(open_nvim)
        if not open_nvim then
          return
        end

        run_command(cmd)

        if open_nvim == "Yes" then
          vim.defer_fn(function()
            open_in_nvim(dir, project_name)
          end, 5000)
        end
      end)
    end)
  end,
  Laravel = function()
    local dir = get_project_dir()
    local project_name = vim.fn.input("Project name: ")
    if project_name == "" then
      project_name = "laravel-app"
    end

    vim.ui.select({ "Basic", "With Jetstream", "With Breeze" }, {
      prompt = "Select variant:",
    }, function(variant)
      if not variant then
        return
      end

      local cmd = "cd " .. dir .. " && composer create-project laravel/laravel " .. project_name

      if variant == "With Jetstream" then
        vim.ui.select({ "Livewire", "Inertia" }, {
          prompt = "Select stack:",
        }, function(stack)
          if not stack then
            return
          end

          run_command(cmd)
          vim.cmd("sleep 5000m")
          run_command("cd " .. project_name .. " && composer require laravel/jetstream")
          run_command("cd " .. project_name .. " && php artisan jetstream:install " .. string.lower(stack))

          vim.ui.select({ "Yes", "No" }, {
            prompt = "Open in Neovim?",
          }, function(open_nvim)
            if open_nvim == "Yes" then
              vim.defer_fn(function()
                open_in_nvim(dir, project_name)
              end, 5000)
            end
          end)
        end)
      elseif variant == "With Breeze" then
        run_command(cmd)
        vim.cmd("sleep 5000m")
        run_command("cd " .. project_name .. " && composer require laravel/breeze --dev")
        run_command("cd " .. project_name .. " && php artisan breeze:install")

        vim.ui.select({ "Yes", "No" }, {
          prompt = "Open in Neovim?",
        }, function(open_nvim)
          if open_nvim == "Yes" then
            vim.defer_fn(function()
              open_in_nvim(dir, project_name)
            end, 5000)
          end
        end)
      else
        vim.ui.select({ "Yes", "No" }, {
          prompt = "Open in Neovim after creation?",
        }, function(open_nvim)
          if not open_nvim then
            return
          end

          run_command(cmd)

          if open_nvim == "Yes" then
            vim.defer_fn(function()
              open_in_nvim(dir, project_name)
            end, 5000)
          end
        end)
      end
    end)
  end,
  Django = function()
    local dir = get_project_dir()
    local project_name = vim.fn.input("Project name: ")
    if project_name == "" then
      project_name = "django_project"
    end

    local cmd = "cd " .. dir .. " && django-admin startproject " .. project_name

    vim.ui.select({ "Yes", "No" }, {
      prompt = "Open in Neovim after creation?",
    }, function(open_nvim)
      if not open_nvim then
        return
      end

      run_command(cmd)

      if open_nvim == "Yes" then
        vim.defer_fn(function()
          open_in_nvim(dir, project_name)
        end, 5000)
      end
    end)
  end,
  Rails = function()
    local dir = get_project_dir()
    local project_name = vim.fn.input("Project name: ")
    if project_name == "" then
      project_name = "rails_app"
    end

    local databases = { "postgresql", "mysql", "sqlite3", "oracle", "sqlserver" }

    vim.ui.select(databases, {
      prompt = "Select database:",
    }, function(db)
      if not db then
        return
      end

      vim.ui.select({ "Full", "API only", "Minimal" }, {
        prompt = "Select type:",
      }, function(app_type)
        if not app_type then
          return
        end

        local cmd = "cd " .. dir .. " && rails new " .. project_name .. " --database=" .. db
        if app_type == "API only" then
          cmd = cmd .. " --api"
        end
        if app_type == "Minimal" then
          cmd = cmd .. " --minimal"
        end

        vim.ui.select({ "Yes", "No" }, {
          prompt = "Open in Neovim after creation?",
        }, function(open_nvim)
          if not open_nvim then
            return
          end

          run_command(cmd)

          if open_nvim == "Yes" then
            vim.defer_fn(function()
              open_in_nvim(dir, project_name)
            end, 5000)
          end
        end)
      end)
    end)
  end,
  ["SvelteKit"] = function()
    local dir = get_project_dir()
    local project_name = vim.fn.input("Project name: ")
    if project_name == "" then
      project_name = "sveltekit-app"
    end

    local variants = {
      ["Skeleton (TypeScript)"] = "skeleton",
      ["Skeleton (JavaScript)"] = "skeleton-js",
      ["Library (TypeScript)"] = "library",
      ["Demo (TypeScript)"] = "demo",
    }

    vim.ui.select(vim.tbl_keys(variants), {
      prompt = "Select template:",
    }, function(template_name)
      if not template_name then
        return
      end

      local template = variants[template_name]
      local cmd = "cd " .. dir .. " && npm create svelte@latest " .. project_name .. " -- --template=" .. template

      vim.ui.select({ "Yes", "No" }, {
        prompt = "Open in Neovim after creation?",
      }, function(open_nvim)
        if not open_nvim then
          return
        end

        run_command(cmd)

        if open_nvim == "Yes" then
          vim.defer_fn(function()
            open_in_nvim(dir, project_name)
          end, 5000)
        end
      end)
    end)
  end,
  SolidJS = function()
    local dir = get_project_dir()
    local project_name = vim.fn.input("Project name: ")
    if project_name == "" then
      project_name = "solid-app"
    end

    vim.ui.select({ "TypeScript", "JavaScript" }, {
      prompt = "Select variant:",
    }, function(variant)
      if not variant then
        return
      end

      local cmd = "cd " .. dir .. " && npx degit solidjs/templates/" .. string.lower(variant) .. " " .. project_name

      vim.ui.select({ "Yes", "No" }, {
        prompt = "Open in Neovim after creation?",
      }, function(open_nvim)
        if not open_nvim then
          return
        end

        run_command(cmd)
        run_command("cd " .. project_name .. " && npm install")

        if open_nvim == "Yes" then
          vim.defer_fn(function()
            open_in_nvim(dir, project_name)
          end, 5000)
        end
      end)
    end)
  end,
  Qwik = function()
    local dir = get_project_dir()
    local project_name = vim.fn.input("Project name: ")
    if project_name == "" then
      project_name = "qwik-app"
    end

    local cmd = "cd " .. dir .. " && npm create qwik@latest " .. project_name

    vim.ui.select({ "Yes", "No" }, {
      prompt = "Open in Neovim after creation?",
    }, function(open_nvim)
      if not open_nvim then
        return
      end

      run_command(cmd)

      if open_nvim == "Yes" then
        vim.defer_fn(function()
          open_in_nvim(dir, project_name)
        end, 5000)
      end
    end)
  end,
  Remix = function()
    local dir = get_project_dir()
    local project_name = vim.fn.input("Project name: ")
    if project_name == "" then
      project_name = "remix-app"
    end

    local cmd = "cd " .. dir .. " && npx create-remix@latest " .. project_name

    vim.ui.select({ "Yes", "No" }, {
      prompt = "Open in Neovim after creation?",
    }, function(open_nvim)
      if not open_nvim then
        return
      end

      run_command(cmd)

      if open_nvim == "Yes" then
        vim.defer_fn(function()
          open_in_nvim(dir, project_name)
        end, 5000)
      end
    end)
  end,
  Gatsby = function()
    local dir = get_project_dir()
    local project_name = vim.fn.input("Project name: ")
    if project_name == "" then
      project_name = "gatsby-site"
    end

    local cmd = "cd " .. dir .. " && npm init gatsby " .. project_name

    vim.ui.select({ "Yes", "No" }, {
      prompt = "Open in Neovim after creation?",
    }, function(open_nvim)
      if not open_nvim then
        return
      end

      run_command(cmd)

      if open_nvim == "Yes" then
        vim.defer_fn(function()
          open_in_nvim(dir, project_name)
        end, 5000)
      end
    end)
  end,
  Angular = function()
    local dir = get_project_dir()
    local project_name = vim.fn.input("Project name: ")
    if project_name == "" then
      project_name = "angular-app"
    end

    local cmd = "cd " .. dir .. " && npx @angular/cli new " .. project_name

    vim.ui.select({ "Yes", "No" }, {
      prompt = "Open in Neovim after creation?",
    }, function(open_nvim)
      if not open_nvim then
        return
      end

      run_command(cmd)

      if open_nvim == "Yes" then
        vim.defer_fn(function()
          open_in_nvim(dir, project_name)
        end, 5000)
      end
    end)
  end,
  Electron = function()
    local dir = get_project_dir()
    local project_name = vim.fn.input("Project name: ")
    if project_name == "" then
      project_name = "electron-app"
    end

    local cmd = "cd " .. dir .. " && npx create-electron-app " .. project_name

    vim.ui.select({ "Yes", "No" }, {
      prompt = "Open in Neovim after creation?",
    }, function(open_nvim)
      if not open_nvim then
        return
      end

      run_command(cmd)

      if open_nvim == "Yes" then
        vim.defer_fn(function()
          open_in_nvim(dir, project_name)
        end, 5000)
      end
    end)
  end,
  ReactNative = function()
    local dir = get_project_dir()
    local project_name = vim.fn.input("Project name: ")
    if project_name == "" then
      project_name = "react-native-app"
    end

    local cmd = "cd " .. dir .. " && npx react-native init " .. project_name

    vim.ui.select({ "Yes", "No" }, {
      prompt = "Open in Neovim after creation?",
    }, function(open_nvim)
      if not open_nvim then
        return
      end

      run_command(cmd)

      if open_nvim == "Yes" then
        vim.defer_fn(function()
          open_in_nvim(dir, project_name)
        end, 5000)
      end
    end)
  end,
  Flutter = function()
    local dir = get_project_dir()
    local project_name = vim.fn.input("Project name: ")
    if project_name == "" then
      project_name = "flutter_app"
    end

    local cmd = "cd " .. dir .. " && flutter create " .. project_name

    vim.ui.select({ "Yes", "No" }, {
      prompt = "Open in Neovim after creation?",
    }, function(open_nvim)
      if not open_nvim then
        return
      end

      run_command(cmd)

      if open_nvim == "Yes" then
        vim.defer_fn(function()
          open_in_nvim(dir, project_name)
        end, 5000)
      end
    end)
  end,
}

function M.merge_commands()
  local merged = {}
  for category, subcats in pairs(commands_db) do
    merged[category] = merged[category] or {}
    for subcat, cmds in pairs(subcats) do
      merged[category][subcat] =
        vim.tbl_extend("keep", cmds, user_commands[category] and user_commands[category][subcat] or {})
    end
  end

  for category, subcats in pairs(user_commands) do
    merged[category] = merged[category] or {}
    for subcat, cmds in pairs(subcats) do
      merged[category][subcat] = vim.tbl_extend("keep", cmds, merged[category][subcat] or {})
    end
  end

  return merged
end

function M.merge_projects()
  return vim.tbl_extend("keep", user_projects, projects_db)
end

function M.create_command_selector()
  local all_commands = M.merge_commands()

  local categories = vim.tbl_keys(all_commands)
  table.sort(categories)

  vim.ui.select(categories, {
    prompt = "Select Category:",
  }, function(category)
    if not category then
      return
    end

    local subcategories = vim.tbl_keys(all_commands[category])
    table.sort(subcategories)

    vim.ui.select(subcategories, {
      prompt = "Select " .. category .. " Tool:",
    }, function(subcategory)
      if not subcategory then
        return
      end

      local commands = vim.tbl_keys(all_commands[category][subcategory])
      table.sort(commands)

      vim.ui.select(commands, {
        prompt = "Select " .. subcategory .. " Command:",
      }, function(command_name)
        if not command_name then
          return
        end

        local command_string = all_commands[category][subcategory][command_name]

        if command_string:match("package_name") then
          local pkg = vim.fn.input("Package name: ")
          if pkg ~= "" then
            command_string = command_string:gsub("package_name", pkg)
          end
        end

        if command_string:match("container_id") then
          local container = vim.fn.input("Container ID: ")
          if container ~= "" then
            command_string = command_string:gsub("container_id", container)
          end
        end

        if command_string:match("pid") then
          local pid = vim.fn.input("Process ID: ")
          if pid ~= "" then
            command_string = command_string:gsub("pid", pid)
          end
        end

        if command_string:match("service_name") then
          local service = vim.fn.input("Service name: ")
          if service ~= "" then
            command_string = command_string:gsub("service_name", service)
          end
        end

        if command_string:match("branch_name") then
          local branch = vim.fn.input("Branch name: ")
          if branch ~= "" then
            command_string = command_string:gsub("branch_name", branch)
          end
        end

        run_command(command_string)
      end)
    end)
  end)
end

function M.create_project_selector()
  local all_projects = M.merge_projects()

  local project_names = vim.tbl_keys(all_projects)
  table.sort(project_names)

  vim.ui.select(project_names, {
    prompt = "Create Project:",
  }, function(project_name)
    if not project_name then
      return
    end

    all_projects[project_name]()
  end)
end

function M.add_command(category, subcategory, name, command)
  add_custom_command(category, subcategory, name, command)
end

function M.add_project(name, config_func)
  add_custom_project(name, config_func)
end

function M.list_categories()
  local all_commands = M.merge_commands()
  return vim.tbl_keys(all_commands)
end

function M.list_commands(category)
  local all_commands = M.merge_commands()
  if all_commands[category] then
    return all_commands[category]
  end
  return {}
end

function M.setup() end

return M
