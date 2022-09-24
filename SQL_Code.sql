/***************** CREATE TABLES *****************/
-- create employees table
CREATE TABLE `employees` (
  `id` int NOT NULL,
  `first_name` varchar(45) NOT NULL,
  `last_name` varchar(45) NOT NULL,
  `d_o_b` date NOT NULL,
  `job_title` varchar(100) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `id_UNIQUE` (`id`)
);

-- create roles table
CREATE TABLE `roles` (
  `id` int NOT NULL,
  `name` varchar(45) DEFAULT NULL,
  `description` varchar(200) DEFAULT NULL,
  `created_by` int DEFAULT NULL,
  `date_created` date DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `id_UNIQUE` (`id`)
);

-- create incidents table
CREATE TABLE `incidents` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(45) NOT NULL,
  `description` varchar(200) NOT NULL,
  `prio` varchar(20) NOT NULL,
  `status` varchar(45) NOT NULL,
  `reporter` int NOT NULL,
  `date_created` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `id_UNIQUE` (`id`)
);

-- create employee_roles table
CREATE TABLE `employee_roles` (
  `employee_id` int NOT NULL,
  `role_id` int NOT NULL,
  `incident_id` int NOT NULL,
  `assigned_by` int NOT NULL,
  `date_assigned` date NOT NULL,
  PRIMARY KEY (`employee_id`,`role_id`,`incident_id`)
);


-- create tasks table
CREATE TABLE `tasks` (
  `incident_id` int NOT NULL,
  `task_id` int NOT NULL,
  `title` varchar(45) NOT NULL,
  `description` varchar(200) NOT NULL,
  `status` varchar(45) NOT NULL,
  `date_created` datetime NOT NULL,
  `assigner` int NOT NULL,
  `assignee` int DEFAULT NULL,
  PRIMARY KEY (`task_id`,`incident_id`)
);

-- create logs table
CREATE TABLE `logs` (
  `incident_id` int NOT NULL,
  `log_id` int NOT NULL,
  `title` varchar(100) NOT NULL,
  `description` varchar(200) NOT NULL,
  `date` datetime NOT NULL,
  PRIMARY KEY (`incident_id`,`log_id`)
);


/***************** TRIGGERS *********************************/
-- Before adding an employee role
CREATE DEFINER=`root`@`localhost` TRIGGER `employee_roles_BEFORE_INSERT` BEFORE INSERT ON `employee_roles` FOR EACH ROW BEGIN
	declare firstname varchar(45);
    declare lastname varchar(45);
	declare fullname varchar(91);
    declare rolename varchar(45);
    declare logmessage varchar(200);
    
    select first_name
    into firstname
    from db.employees
    where employees.id = new.employee_id;
    
    select last_name
    into lastname
    from db.employees
    where employees.id = new.employee_id;
    
    select name
    into rolename
    from roles
    where roles.id = new.role_id;
    
    set fullname = concat(concat(firstname,' '),lastname);
    set logmessage = concat_ws(' ',fullname,'was assigned the role of: ',rolename);
	call addLog(new.incident_id, 'New role assigned',logmessage);
END

-- Before removing an employee role
CREATE DEFINER=`root`@`localhost` TRIGGER `employee_roles_BEFORE_DELETE` BEFORE DELETE ON `employee_roles` FOR EACH ROW BEGIN
	declare firstname varchar(45);
    declare lastname varchar(45);
	declare fullname varchar(91);
    declare rolename varchar(45);
    declare logmessage varchar(200);
    
    select first_name
    into firstname
    from db.employees
    where employees.id = old.employee_id;
    
    select last_name
    into lastname
    from db.employees
    where employees.id = old.employee_id;
    
    select name
    into rolename
    from roles
    where roles.id = old.role_id;
    
    set fullname = concat(concat(firstname,' '),lastname);
	call addLog(old.incident_id,'Removed role',concat_ws(' ',fullname,'is no longer',rolename));
END

-- Before reporting an incident
CREATE DEFINER=`root`@`localhost` TRIGGER `incidents_BEFORE_INSERT` BEFORE INSERT ON `incidents` FOR EACH ROW BEGIN
	call addLog(new.id, concat('Incident Reported: ',new.name),'The incident was reported');
END

-- Before marking an incident as resolved
CREATE DEFINER=`root`@`localhost` TRIGGER `incidents_BEFORE_UPDATE` BEFORE UPDATE ON `incidents` FOR EACH ROW BEGIN
	call addLog(new.id, concat(new.name,' resolved'), 'The incident was resolved');
END

-- Before adding a task
CREATE DEFINER=`root`@`localhost` TRIGGER `tasks_BEFORE_INSERT` BEFORE INSERT ON `tasks` FOR EACH ROW BEGIN

    declare logcount int;

    select count(*)
    into logcount
    from db.logs
    where incident_id = new.incident_id;

    call addLog(new.incident_id, concat('New Task Added: ', new.title), new.description);
END

-- Before resolving a task
CREATE DEFINER=`root`@`localhost` TRIGGER `tasks_BEFORE_UPDATE` BEFORE UPDATE ON `tasks` FOR EACH ROW BEGIN
	call addLog(old.incident_id, concat_ws(' ',old.title,'was resolved'),'The task was resolved');
END

/***************** POPULATE TABLES *****************/
-- populate employees table
call addEmployee(0,'Jonathan','Cicai','2002-08-03','CEO');
call addEmployee(2,'John','Doe','1999-01-01','Unknown');
call addEmployee(56,'Connor','Jameson','2000-11-18','Intern Frontend Developer');
call addEmployee(146,'Blake','Dunne','1989-09-14','Senior Full Stack Developer');
call addEmployee(192,'Dominic','Tran','1990-08-05','Senior Software Engineer');
call addEmployee(298,'Clare','Reily','1998-06-25','Junior Software Developer');
call addEmployee(315,'Jack','Akintola',	'1985-07-09','Creative Lead');
call addEmployee(401,'Mathias','Moses','2000-12-05','Intern');
call addEmployee(843,'Joe','Waldron','1995-10-18','Senior Backend Developer');

-- populate roles table
call db.addRole(1, 'Incident Lead', 'The leader of the team in charge of the incident', 0);
call db.addRole(2, 'Frontend Lead', 'The main person in charge of the frontend', 0);
call db.addRole(3, 'Backend Lead', 'The main person in charge of the backend', 0);
call db.addRole(4, 'Frontend Aid', 'An aid to the Frontend Lead', 0);
call db.addRole(5, 'Backend Aid', 'An aid to the Backend Lead', 0);
call db.addRole(6, 'General Aid', 'Aid with general tasks (like printing)', 0);

-- populate incidents table
call db.reportIncident(111, 'Dashboard Broken', 'The dashboard is not loading', 'Major', 192);
call db.reportIncident(292, 'Server Not Responding', 'The website server is unresponsive', 'Severe', 843);
call db.reportIncident(384, 'Broken Animation', 'The loading bar on the homepage does not work', 'minor', 56);
call db.reportIncident(495, 'Slow Rendering', 'The website is rendering slowly', 'Major', 0);
call db.reportIncident(684, 'Login broken', 'The users of the website cannot log in', 'major', 2);


-- populate employee_roles table
call db.addEmployeeRole(843, 3, 292, 0);
call db.addEmployeeRole(56, 2, 111, 0);
call db.addEmployeeRole(146, 1, 495, 0);
call db.addEmployeeRole(56, 2, 495, 0);
call db.addEmployeeRole(843, 3, 495, 0);
call db.addEmployeeRole(298, 1, 384, 0);
call db.addEmployeeRole(401, 1, 684, 192);
call db.addEmployeeRole(0, 4, 111, 0);

-- populate tasks table
call db.addTask(292, 1, 'Determine Cause', 'Find out why server is broken', 843, 843);
call db.addTask(292, 1, 'Determine Cause', 'Determine what the cause is', 0, 146);
call db.addTask(111, 1, 'Check database ', 'Check if the issue is frontend or backend related', 298, 298);
call db.addTask(384, 1, 'Resolve issue', 'Try to resolve the issue', 384, 384);
call db.addTask(684, 1, 'Assemble Team', 'Assemble a team to help with the incident', 401, 401);

-- logs table is populated by triggers in the incidents, employee_roles and tasks tables

/***************** PROCEDURES *****************/
-- add employee
CREATE DEFINER=`root`@`localhost` PROCEDURE `addEmployee`(
		IN employeeID INT,
        IN fname VARCHAR(45),
        IN lname VARCHAR(45),
        IN dob DATE,
        IN job_title VARCHAR(100)
        
)
BEGIN
	INSERT INTO `db`.`employees` (`id`, `first_name`, `last_name`, `d_o_b`, `job_title`) VALUES (employeeID, fname, lname, dob, job_title);
END

-- add employee role
CREATE DEFINER=`root`@`localhost` PROCEDURE `addEmployeeRole`(
	in employee_id int,
    in role_id int,
    in incident_id int,
    in assigned_by int
)
BEGIN
	insert into `db`.`employee_roles`(`employee_id`,`role_id`,`incident_id`,`assigned_by`,`date_assigned`) values(employee_id, role_id, incident_id, assigned_by, curdate());
END

-- add log
CREATE DEFINER=`root`@`localhost` PROCEDURE `addLog`(
    in incident_id int,
    in title varchar(45),
    in description varchar(200)
)
BEGIN
	declare lognum int;

    select count(*)
    into lognum
    from db.logs
    where logs.incident_id = incident_id;
    
    INSERT INTO `db`.`logs` (`incident_id`,`log_id`,`title`,`description`,`date`) 
    VALUES (incident_id, lognum+1, title, description, now());
END

-- add role
CREATE DEFINER=`root`@`localhost` PROCEDURE `addRole`(
	in id int,
    in name varchar(45),
    in description varchar(200),
    in created_by int
)
BEGIN
	insert into `db`.`roles`(`id`,`name`,`description`,`created_by`,`date_created`)
    values(id, name, description, created_by, curdate());
END

-- add task
CREATE DEFINER=`root`@`localhost` PROCEDURE `addTask`(
    in incident_id int,
    in task_id int, 
    in title varchar(45),
    in description varchar(200),
    in assigner int,
    in assignee int
)
BEGIN
    INSERT INTO `db`.`tasks` (`incident_id`,`task_id`,`title`,`description`,`status`,`date_created`,`assigner`,`assignee`) 
    VALUES (incident_id, task_id, title, description, 'In Progress', now(), assigner, assignee);

END

-- report incident
CREATE DEFINER=`root`@`localhost` PROCEDURE `reportIncident`(
    in id int,
    in name varchar(45),
    in description varchar(200),
    in priority varchar(20),
    in reporter int
)
BEGIN
    INSERT INTO `db`.`incidents` (`id`, `name`, `description`, `prio`, `status`,   `reporter`,`date_created`) 
    VALUES (id,name,description,priority,'In Progress',reporter, now());

END

-- resolve incident
CREATE DEFINER=`root`@`localhost` PROCEDURE `resolveIncident`(
    in id int
)
BEGIN
    update db.incidents
    set status = 'Resolved'
    where incidents.id = id;
END

-- resolve task
CREATE DEFINER=`root`@`localhost` PROCEDURE `resolveTask`(
	in incident_id int,
    in task_id int
)
BEGIN
	update db.tasks
    set status = 'Resolved'
    where tasks.incident_id = incident_id and tasks.task_id = task_id;
END

-- remove employee role
CREATE DEFINER=`root`@`localhost` PROCEDURE `removeEmployeeRole`(
	in employee_id int,
    in role_id int,
    in incident_id int
)
BEGIN
	delete from db.employee_roles where employee_roles.employee_id = employee_id and employee_roles.role_id = role_id and employee_roles.incident_id = incident_id;
END


/***************** VIEWS *****************/
-- IncidentTeams View
CREATE 
    ALGORITHM = UNDEFINED 
    DEFINER = `root`@`localhost` 
    SQL SECURITY DEFINER
VIEW `incidentteams` AS
    SELECT 
        `i`.`id` AS `id`,
        `i`.`name` AS `name`,
        `er`.`employee_id` AS `employee_id`,
        `e`.`first_name` AS `first_name`,
        `e`.`last_name` AS `last_name`
    FROM
        ((`incidents` `i`
        JOIN `employee_roles` `er`)
        JOIN `employees` `e`)
    WHERE
        ((`i`.`id` = `er`.`incident_id`)
            AND (`er`.`employee_id` = `e`.`id`))