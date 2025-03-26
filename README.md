<div align="left" style="position: relative;">
<img src="https://000009.awsstudygroup.com/images/serviceicon.png?featherlight=false&width=10pc" align="right" width="20%" style="margin: -20px 0 0 20px;">
<h1>ZENDESK-AWS-SUPPORT</h1>
<p align="left">
	<em>Bridging Support, Powering Solutions!</em>
</p>
<p align="left">
	<img src="https://img.shields.io/github/license/flozonn/zendesk-aws-support?style=plastic&logo=opensourceinitiative&logoColor=white&color=546eeb" alt="license">
	<img src="https://img.shields.io/github/last-commit/flozonn/zendesk-aws-support?style=plastic&logo=git&logoColor=white&color=546eeb" alt="last-commit">
	<img src="https://img.shields.io/github/languages/top/flozonn/zendesk-aws-support?style=plastic&color=546eeb" alt="repo-top-language">
	<img src="https://img.shields.io/github/languages/count/flozonn/zendesk-aws-support?style=plastic&color=546eeb" alt="repo-language-count">
</p>
<p align="left">Built with the tools and technologies:</p>
<p align="left">
	<img src="https://img.shields.io/badge/Python-3776AB.svg?style=plastic&logo=Python&logoColor=white" alt="Python">
	<img src="https://img.shields.io/badge/Terraform-844FBA.svg?style=plastic&logo=Terraform&logoColor=white" alt="Terraform">
    <img src="https://img.shields.io/badge/AWS-%23FF9900.svg?logo=amazon-web-services&logoColor=white" alt="Terraform">
    <img src="https://img.shields.io/badge/-Zendesk-03363D?style=flat&logo=zendesk&logoColor=white"/>

</p>
</div>
<br clear="right">

## 🔗 Table of Contents

- [📍 Overview](#-overview)  
- [👾 Features](#-features)  
- [📁 Project Structure](#-project-structure)  
  - [📂 Project Index](#-project-index)  
- [🚀 Getting Started](#-getting-started)  
  - [☑️ Prerequisites](#-prerequisites)  
  - [⚙️ Installation](#-installation)  
  - [🤖 Zendesk Configuration](#-zendesk-configuration)  
- [🔰 Contributing](#-contributing)

---

## 📍 Overview

The zendesk-aws-support project is a powerful bridge between Zendesk and AWS, enabling seamless case management and communication across both platforms. It leverages AWS Lambda functions and EventBridge to handle Zendesk webhooks and AWS support case events, while storing data in an S3 bucket. This open-source solution is ideal for businesses seeking to synchronize their customer support efforts on AWS and Zendesk, enhancing efficiency and response times.

---

## 👾 Features

|      | Feature         | Summary       |
| :--- | :---:           | :---          |
| ⚙️  | **Architecture**  | <ul><li>Event-driven architecture with AWS Lambda functions and EventBridge.</li><li>Uses AWS S3 for data storage and retrieval.</li><li>Codebase is primarily written in `Terraform` and `Python`.</li></ul> |
| 🔩 | **Code Quality**  | <ul><li>Code is modular and well-structured, with clear separation of concerns.</li><li>Scripts are written in Python, following good coding practices.</li><li>Terraform scripts are used for infrastructure as code, ensuring reproducibility and consistency.</li></ul> |
| 🔌 | **Integrations**  | <ul><li>Integrates with Zendesk for ticket management.</li><li>Uses AWS services like Lambda, S3, EventBridge, and IAM.</li><li>Webhooks are used for real-time updates between Zendesk and AWS.</li></ul> |
| 🧩 | **Modularity**    | <ul><li>Codebase is divided into separate Python scripts and Terraform files for different functionalities.</li><li>Each Lambda function has its own dedicated script and Terraform file.</li><li>Variables are defined in a separate `variables.tf` file for easy configuration.</li></ul> |
| 🛡️ | **Security**      | <ul><li>Webhook signatures are verified for authenticity.</li><li>Uses IAM roles and policies for secure access to AWS resources.</li><li>S3 bucket is private, ensuring data security.</li></ul> |
| 📦 | **Dependencies**  | <ul><li>Project uses `Terraform` for infrastructure as code.</li><li>Python scripts are used for AWS Lambda functions.</li><li>`.terraform.lock.hcl` file indicates the use of Terraform 0.14 or later.</li></ul> |

---

## 📁 Project Structure

```sh
└── zendesk-aws-support/
    ├── README.md
    ├── lambdaAwsToZendesk
    │   └── lambdaAwsToZendesk.py
    ├── lambdaWebhooksToEventBridge
    │   └── lambdaWebhooksToEventBridge.py
    ├── lambdaZendeskToAws
    │   └── lambdaZendeskToAws.py
    ├── platform
    │   ├── .terraform.lock.hcl
    │   ├── bucket.tf
    │   ├── eventbridge.tf
    │   ├── lambdaAwsToZendesk.tf
    │   ├── lambdaWebhooksToEventBridge.tf
    │   ├── lambdaZendeskToAws.tf
    │   ├── provider.tf
    │   └── variables.tf
    └── zendeskResources
        └── sagemaker_category_codes.csv
```


### 📂 Project Index
<details open>
	<summary><b><code>ZENDESK-AWS-SUPPORT/</code></b></summary>
	<details> <!-- __root__ Submodule -->
		<summary><b>__root__</b></summary>
		<blockquote>
			<table>
			</table>
		</blockquote>
	</details>
	<details> <!-- lambdaZendeskToAws Submodule -->
		<summary><b>lambdaZendeskToAws</b></summary>
		<blockquote>
			<table>
			<tr>
				<td><b><a href='https://github.com/flozonn/zendesk-aws-support/blob/master/lambdaZendeskToAws/lambdaZendeskToAws.py'>lambdaZendeskToAws.py</a></b></td>
				<td>- LambdaZendeskToAws.py serves as a bridge between Zendesk and AWS, handling webhooks from Zendesk to create, update, or resolve AWS support cases<br>- It also retrieves and stores data in an S3 bucket, facilitating seamless communication and case management between the two platforms.</td>
			</tr>
			</table>
		</blockquote>
	</details>
	<details> <!-- lambdaAwsToZendesk Submodule -->
		<summary><b>lambdaAwsToZendesk</b></summary>
		<blockquote>
			<table>
			<tr>
				<td><b><a href='https://github.com/flozonn/zendesk-aws-support/blob/master/lambdaAwsToZendesk/lambdaAwsToZendesk.py'>lambdaAwsToZendesk.py</a></b></td>
				<td>- The lambdaAwsToZendesk.py script serves as a bridge between AWS and Zendesk<br>- It logs AWS support case events, retrieves data from an S3 bucket, and updates Zendesk tickets based on these events<br>- The script is particularly useful for synchronizing communication and resolving cases across both platforms.</td>
			</tr>
			</table>
		</blockquote>
	</details>
	<details> <!-- platform Submodule -->
		<summary><b>platform</b></summary>
		<blockquote>
			<table>
			<tr>
				<td><b><a href='https://github.com/flozonn/zendesk-aws-support/blob/master/platform/lambdaWebhooksToEventBridge.tf'>lambdaWebhooksToEventBridge.tf</a></b></td>
				<td>- LambdaWebhooksToEventBridge.tf establishes an AWS Lambda function named 'webhook_lambda' with necessary IAM roles and policies<br>- It enables the function to assume roles, put events in EventBridge, and access support actions<br>- The function, written in Python 3.9, handles webhooks and logs its activities in a dedicated CloudWatch log group<br>- The output is the function's URL.</td>
			</tr>
			<tr>
				<td><b><a href='https://github.com/flozonn/zendesk-aws-support/blob/master/platform/eventbridge.tf'>eventbridge.tf</a></b></td>
				<td>- The 'eventbridge.tf' file in the platform directory sets up AWS EventBridge resources to handle webhook events from Zendesk and AWS support case events<br>- It establishes rules to trigger specific Lambda functions when these events occur, and grants necessary permissions for EventBridge to invoke these functions<br>- This forms a crucial part of the project's event-driven architecture.</td>
			</tr>
			<tr>
				<td><b><a href='https://github.com/flozonn/zendesk-aws-support/blob/master/platform/lambdaAwsToZendesk.tf'>lambdaAwsToZendesk.tf</a></b></td>
				<td>- The 'lambdaAwsToZendesk.tf' file in the 'platform' directory configures a Lambda function to monitor AWS support cases and relay them to Zendesk<br>- It establishes the necessary IAM roles and policies, sets up a CloudWatch log group for tracking, and defines environment variables for the Lambda function<br>- This function serves as a bridge between AWS and Zendesk, enhancing the project's customer support capabilities.</td>
			</tr>
			<tr>
				<td><b><a href='https://github.com/flozonn/zendesk-aws-support/blob/master/platform/bucket.tf'>bucket.tf</a></b></td>
				<td>- Within the platform directory, bucket.tf establishes a private AWS S3 bucket named "case-ids-lookup-12345"<br>- It also outputs the bucket's ID, providing a reference point for other components in the project that may require access to this storage resource.</td>
			</tr>
			<tr>
				<td><b><a href='https://github.com/flozonn/zendesk-aws-support/blob/master/platform/provider.tf'>provider.tf</a></b></td>
				<td>- Platform/provider.tf establishes the AWS provider for the project, setting the geographical region based on a variable<br>- This is a crucial part of the codebase architecture as it determines where the AWS resources for the project will be provisioned.</td>
			</tr>
			<tr>
				<td><b><a href='https://github.com/flozonn/zendesk-aws-support/blob/master/platform/lambdaZendeskToAws.tf'>lambdaZendeskToAws.tf</a></b></td>
				<td>- The 'lambdaZendeskToAws.tf' file in the 'platform' directory configures an AWS Lambda function named 'lambdaZendeskToAws'<br>- This function is designed to interact with an EventBridge bus and an S3 bucket, and logs its activities to a CloudWatch log group<br>- The function's role and permissions are also defined within this file.</td>
			</tr>
			<tr>
				<td><b><a href='https://github.com/flozonn/zendesk-aws-support/blob/master/platform/variables.tf'>variables.tf</a></b></td>
				<td>- The 'variables.tf' file in the 'platform' directory defines key configuration parameters for the project<br>- It specifies deployment region, bucket name for ID lookups, Zendesk API key, tokens for signing POST requests, Zendesk subdomain, and admin email<br>- These variables facilitate the customization and configuration of the project's deployment and interaction with Zendesk services.</td>
			</tr>
			</table>
		</blockquote>
	</details>
	<details> <!-- lambdaWebhooksToEventBridge Submodule -->
		<summary><b>lambdaWebhooksToEventBridge</b></summary>
		<blockquote>
			<table>
			<tr>
				<td><b><a href='https://github.com/flozonn/zendesk-aws-support/blob/master/lambdaWebhooksToEventBridge/lambdaWebhooksToEventBridge.py'>lambdaWebhooksToEventBridge.py</a></b></td>
				<td>- The lambdaWebhooksToEventBridge.py script serves as a bridge between incoming webhooks and AWS EventBridge<br>- It verifies the authenticity of the webhook signature, then forwards the payload to EventBridge<br>- If the signature is invalid or the payload fails to reach EventBridge, it logs the error and returns an appropriate HTTP status code.</td>
			</tr>
			</table>
		</blockquote>
	</details>
</details>

---
## 🚀 Getting Started

### ☑️ Prerequisites

Before getting started with zendesk-aws-support, ensure your runtime environment meets the following requirements:

- **Programming Language:** Terraform


### ⚙️ Installation

Install zendesk-aws-support using one of the following methods:

**Build from source:**

1. Clone the zendesk-aws-support repository:
```sh
❯ git clone https://github.com/flozonn/zendesk-aws-support
```

2. Navigate to the project directory:
```sh
❯ cd zendesk-aws-support
```

3. Install the project dependencies:

```sh
❯ fill the required variables in tofilll.auto.tfvars
❯ make zip
❯ make deploy
```
4. Retrieve the function URL after deployment



### 🤖 Zendesk configuration

#### 1.Create 2 custom fields
First create 2 additional custom fields in the Zendesk form to gather data about Severity, Impacted Service and Category of the case: 
- Field named AWS Service should be a drop down field with serviceCodes value (SageMaker)
- Field named Category code should be a drop down field with all the possible categoryCodes for a give serviceCode (cf file in /zendeskResources directory).
#### 2.Create Webhooks
Then create 3 webhooks:
- aws support - solved, endpoint = https://your_function_url/solved 
- aws support - update, endpoint = https://your_function_url/update 
- aws support - create , endpoint = https://your_function_url/create 

####  3.Create Triggers
From the Zendesk Admin Panel, create **3 triggers** (under *Objects and Rules*).
##### create_ticket_trigger
- **Name:** `create_ticket_trigger`
- **Trigger Category:** Notifications
- **Conditions:**
  - `Ticket > Ticket + Is + Created`
- **Actions:**
  - `Notify by > Active Webhook + aws support - create`
  - **Method:** `POST`
  - **Data:**
    ```json
    { 
      "zd_ticket_id": {{ticket.id}}, 
      "zd_ticket_desc": "{{ticket.description}}",
      "zd_ticket_requester_email": "{{ticket.requester.email}}",
      "zd_ticket_latest_public_comment": "{{ticket.latest_public_comment_html}}",
      "zd_ticket_impacted_service": "{{ticket.ticket_field_<Replace_with_custome_fieldID>}}",
      "zd_ticket_category_code": "{{ticket.ticket_field_<Replace_with_custome_fieldID>}}",
      "zd_ticket_sev_code": "{{ticket.ticket_field_<Replace_with_custome_fieldID>}}"
    }
    ```

---

##### update_ticket_trigger
- **Name:** `update_ticket_trigger`
- **Trigger Category:** Notifications
- **Conditions:**
  - `Ticket > Ticket + Is + Updated`
  - `Ticket > Update Via + Is Not + Web service (API)`
- **Actions:**
  - `Notify by > Active Webhook + aws support - update`
  - **Method:** `POST`
  - **Data:**
    ```json
    { 
      "zd_ticket_id": {{ticket.id}}, 
      "zd_ticket_desc": "{{ticket.description}}",
      "zd_ticket_requester_email": "{{ticket.requester.email}}",
      "zd_ticket_latest_public_comment": "{{ticket.latest_public_comment_html}}"
    }
    ```

---

##### solved_ticket_trigger
- **Name:** `solved_ticket_trigger`
- **Trigger Category:** Notifications
- **Conditions:**
  - `Ticket > Ticket Status + Changed To + Solved`
- **Actions:**
  - `Notify by > Active Webhook + aws support - solved`
  - **Method:** `POST`
  - **Data:**
    ```json
    { 
      "zd_ticket_id": {{ticket.id}}, 
      "zd_ticket_desc": "{{ticket.description}}",
      "zd_ticket_requester_email": "{{ticket.requester.email}}",
      "zd_ticket_latest_public_comment": "{{ticket.latest_public_comment_html}}"
    }
    ```

And finally link the webhooks and triggers.
---

## 🔰 Contributing

- **💬 [Join the Discussions](https://github.com/flozonn/zendesk-aws-support/discussions)**: Share your insights, provide feedback, or ask questions.
- **🐛 [Report Issues](https://github.com/flozonn/zendesk-aws-support/issues)**: Submit bugs found or log feature requests for the `zendesk-aws-support` project.
- **💡 [Submit Pull Requests](https://github.com/flozonn/zendesk-aws-support/blob/main/CONTRIBUTING.md)**: Review open PRs, and submit your own PRs.

<details closed>
<summary>Contributing Guidelines</summary>

1. **Fork the Repository**: Start by forking the project repository to your github account.
2. **Clone Locally**: Clone the forked repository to your local machine using a git client.
   ```sh
   git clone https://github.com/flozonn/zendesk-aws-support
   ```
3. **Create a New Branch**: Always work on a new branch, giving it a descriptive name.
   ```sh
   git checkout -b new-feature-x
   ```
4. **Make Your Changes**: Develop and test your changes locally.
5. **Commit Your Changes**: Commit with a clear message describing your updates.
   ```sh
   git commit -m 'Implemented new feature x.'
   ```
6. **Push to github**: Push the changes to your forked repository.
   ```sh
   git push origin new-feature-x
   ```
7. **Submit a Pull Request**: Create a PR against the original project repository. Clearly describe the changes and their motivations.
8. **Review**: Once your PR is reviewed and approved, it will be merged into the main branch. Congratulations on your contribution!
</details>

<details closed>
<summary>Contributor Graph</summary>
<br>
<p align="left">
   <a href="https://github.com{/flozonn/zendesk-aws-support/}graphs/contributors">
      <img src="https://contrib.rocks/image?repo=flozonn/zendesk-aws-support">
   </a>
</p>
</details>

---
