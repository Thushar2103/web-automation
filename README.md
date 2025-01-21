# WebAuto

Welcome to the WebAuto! This project allows you to define automation tasks through a Flutter-based UI, generate a JSON file, and execute those tasks using Python and Selenium.

## Features

- **User-Friendly Frontend:** Use Flutter's UI to design automation workflows.
- **JSON-Based Task Definition:** Export workflows as a structured JSON file for flexible and reusable automation.
- **Automatic File Storage:** JSON files are saved in the `Documents` folder under a subfolder named `AutoWeb`.
- **Selenium Execution:** Parse and run automation tasks seamlessly in Python using Selenium.

## Technologies Used

- **Frontend:** Flutter
- **Backend:** Python
- **Automation Framework:** Selenium

---

## How It Works

1. **Define Tasks in Flutter UI:**  
   Use the frontend to create a series of automation tasks like navigating to URLs, interacting with web elements, or repeating steps in loops.

2. **Export to JSON:**  
   Save the workflow as a JSON file. The application automatically saves the JSON file in the `Documents/AutoWeb` folder.

3. **Run Automation with Selenium:**  
   The backend parses the JSON file from the `AutoWeb` folder and executes the tasks using Selenium.

---

## Demo

Here is a demonstration of the Web Automation workflow:

[demo](https://drive.google.com/file/d/1ayd33haVWCy-0MnFDXmUx7Q12s_RpstI/view?usp=sharing)

## Example JSON File

Here is an example of a JSON file defining an automation workflow:

---

```json
{
  "steps": [
    {
      "action": "navigate",
      "locatorType": null,
      "value": "https://google.com"
    },
    {
      "action": "loop",
      "repeatCount": 2,
      "steps": [
        {
          "action": "navigate",
          "locatorType": "id",
          "value": "https://google.com"
        },
        {
          "action": "navigate",
          "locatorType": "id",
          "value": "https://netflix.com"
        }
      ]
    },
    {
      "action": "navigate",
      "locatorType": null,
      "value": "https://netflix.com"
    },
    {
      "action": "navigate",
      "locatorType": null,
      "value": "https://amazon.com"
    }
  ]
}
```
=======
# WebAuto

Welcome to the WebAuto! This project allows you to define automation tasks through a Flutter-based UI, generate a JSON file, and execute those tasks using Python and Selenium.

## Features

- **User-Friendly Frontend:** Use Flutter's UI to design automation workflows.
- **JSON-Based Task Definition:** Export workflows as a structured JSON file for flexible and reusable automation.
- **Automatic File Storage:** JSON files are saved in the `Documents` folder under a subfolder named `AutoWeb`.
- **Selenium Execution:** Parse and run automation tasks seamlessly in Python using Selenium.

## Technologies Used

- **Frontend:** Flutter
- **Backend:** Python
- **Automation Framework:** Selenium

---

## How It Works

1. **Define Tasks in Flutter UI:**  
   Use the frontend to create a series of automation tasks like navigating to URLs, interacting with web elements, or repeating steps in loops.

2. **Export to JSON:**  
   Save the workflow as a JSON file. The application automatically saves the JSON file in the `Documents/AutoWeb` folder.

3. **Run Automation with Selenium:**  
   The backend parses the JSON file from the `AutoWeb` folder and executes the tasks using Selenium.

---

## Demo

Here is a demonstration of the Web Automation workflow:

[demo video](screenshots/1.mp4)


## Example JSON File

Here is an example of a JSON file defining an automation workflow:

---

```json
{
  "steps": [
    {
      "action": "navigate",
      "locatorType": null,
      "value": "https://google.com"
    },
    {
      "action": "loop",
      "repeatCount": 2,
      "steps": [
        {
          "action": "navigate",
          "locatorType": "id",
          "value": "https://google.com"
        },
        {
          "action": "navigate",
          "locatorType": "id",
          "value": "https://netflix.com"
        }
      ]
    },
    {
      "action": "navigate",
      "locatorType": null,
      "value": "https://netflix.com"
    },
    {
      "action": "navigate",
      "locatorType": null,
      "value": "https://amazon.com"
    }
  ]
}
```
>>>>>>> e8fd615a2f02359333a9d582919497d5c6a4bbc1
