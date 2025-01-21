import json
import time
import sys
from selenium import webdriver
from selenium.webdriver.common.by import By

# Function to execute automation steps and track the result of each step
def execute_automation(json_data):
    driver = webdriver.Edge()  # Replace with appropriate driver (e.g., Chrome, Edge)
    step_results = []

    try:
        for index, step in enumerate(json_data['steps']):
            result = execute_step(driver, step, index + 1)
            step_results.append(result)
        return {"status": "success", "message": "Automation completed successfully.", "results": step_results}
    except Exception as e:
        return {"status": "failure", "message": f"Error during automation: {e}", "results": step_results}
    finally:
        driver.quit()

# Function to execute a single step and return the result
def execute_step(driver, step, step_number):
    action = step['action']
    value = step.get('value', '')
    locator_type = step.get('locatorType', 'id')
    keys = step.get('keys', '')  # For sendKeys action
    result = {
        "step": step_number,
        "action": action,
        "status": "success",
        "message": ""
    }

    try:
        if action == 'navigate':
            driver.get(value)
            result["message"] = f"Navigated to {value}"
        elif action == 'screenshot':
            driver.save_screenshot("screenshot.png")
            result["message"] = "Screenshot taken."
        elif action == 'click':
            element = find_element(driver, locator_type, value)
            element.click()
            result["message"] = f"Clicked on element with {locator_type}: {value}"
        elif action == 'wait':
            time.sleep(int(value))  # Assuming value is in seconds
            result["message"] = f"Waited for {value} seconds"
        elif action == 'sendKeys':
            element = find_element(driver, locator_type, value)
            element.send_keys(keys)
            result["message"] = f"Sent keys {keys} to element with {locator_type}: {value}"
        elif action == 'loop':
            repeat_count = step.get('repeatCount', 1)
            loop_steps = step.get('steps', [])
            result["message"] = f"Looped {repeat_count} times"
            for _ in range(repeat_count):
                for loop_step in loop_steps:
                    execute_step(driver, loop_step, step_number)
        else:
            result["status"] = "failure"
            result["message"] = f"Unknown action: {action}"
    except Exception as e:
        result["status"] = "failure"
        result["message"] = f"Error executing step: {e}"

    return result

# Function to find an element based on the locator type
def find_element(driver, locator_type, value):
    if locator_type == 'id':
        return driver.find_element(By.ID, value)
    elif locator_type == 'xpath':
        return driver.find_element(By.XPATH, value)
    elif locator_type == 'css selector':
        return driver.find_element(By.CSS_SELECTOR, value)
    else:
        raise ValueError(f"Unknown locator type: {locator_type}")

# Main function to run the automation
def run_automation(json_file):
    try:
        with open(json_file, 'r') as file:
            automation_data = json.load(file)
        response = execute_automation(automation_data)
        return response
    except json.JSONDecodeError as e:
        return {"status": "failure", "message": f"Invalid JSON input: {e}", "results": []}
    except FileNotFoundError as e:
        return {"status": "failure", "message": f"File not found: {e}", "results": []}

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python automate.py '<json_file>'")
        sys.exit(1)

    json_file = sys.argv[1]
    response = run_automation(json_file)

    # Print the response with step-by-step results
    print(json.dumps(response, indent=4))
