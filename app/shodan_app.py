from flask import Flask, request, render_template # Import the Flask class from the flask module
import shodan # Import the Shodan library
import logging # Import the logging module
import os # Import the OS module
import csv # Import the CSV module

app = Flask(__name__) # Create an instance of the Flask class with the name of the running application as the argument

# Load the Shodan API key from environment variables
shodan_secret = os.getenv('SHODAN_API_KEY') # Get the SHODAN_API_KEY from environment variables

# Ensure the API key is available
if not shodan_secret:
    raise ValueError("No SHODAN_API_KEY found in environment variables.") # Raise a ValueError if the SHODAN_API_KEY is not found

api = shodan.Shodan(shodan_secret) # Create an instance of the Shodan class with the API key as the argument to authenticate the API

# Configure logging
logging.basicConfig(level=logging.DEBUG) 
@app.route('/') # Define a route for the root URL
def home(): # Define a function to return the home page
    return render_template('home.html') # Return the home.html template

@app.route('/search_by_ip') # Define a route for the search_by_ip URL
def search_by_ip(): # Define a function to return the search_by_ip page
    return render_template('search_by_ip.html') # Return the search_by_ip.html template

@app.route('/search_by_filters') # Define a route for the search_by_filters URL
def search_by_filters(): # Define a function to return the search_by_filters page
    return render_template('search_by_filters.html') # Return the search_by_filters.html template

@app.route('/perform_ip_search', methods=['POST']) # Define a route for the perform_ip_search URL with the POST method
def perform_ip_search():
    ip = request.form.get('ip') # Get the IP address from the form data
    try:
        logging.debug(f"Searching for IP: {ip}")
        results = api.host(ip) # Search for the IP address using the Shodan API Get host method
        logging.debug(f"Results: {results}")
        # Save the results to a JSON file
        return render_template('host_results.html', results=results) # Render the host_results.html template with the search results
    except shodan.APIError as e: # Handle Shodan API errors
        logging.error(f"Shodan API Error: {str(e)}")
        return f"Error: {str(e)}" # Return the error message e contain the error message.
    except Exception as e: # Handle unexpected errors
        logging.error(f"Unexpected Error: {str(e)}")
        return f"Unexpected Error: {str(e)}" # Return the error message e contain the error message.

@app.route('/perform_filter_search', methods=['POST']) # Define a route for the perform_filter_search URL with the POST method
def perform_filter_search(): # Define a function to perform a search with filters
    port = request.form.get('port') # Get the port number from the form data
    country = request.form.get('country') # Get the country code from the form data
    product = request.form.get('product') # Get the product name from the form data
    os = request.form.get('os')    # Get the operating system name from the form data
    category = request.form.get('category') # Get the category name from the form data


    filters = [] # Create an empty list to store the filters
    if port: # Check if the port number is provided
        filters.append(f'port:{port}') # Add the port filter to the list
    if country: # Check if the country code is provided
        filters.append(f'country:{country}') # Add the country filter to the list
    if product: # Check if the product name is provided
        filters.append(f'product:{product}') # Add the product filter to the list
    if os: # Check if the operating system name is provided
        filters.append(f'os:{os}') # Add the operating system filter to the list
    if category: # Check if the category name is provided
        filters.append(f'category:{category}') # Add the category filter to the list
    
    query = ' '.join(filters) # Join the filters list into a single string with spaces
    try: # Try to search with the filters
        logging.debug(f"Searching with query: {query}")
        results = api.search(query) # Search with the query using the Shodan API search method
        # Save the results to a CSV file 'a' is for append mode to add new results to the existing file
        with open('shodan_results.csv', 'a', newline='') as csvfile: # Open the CSV file in append mode with the name shodan_results.csv
            # Define the CSV column headers
            fieldnames = ['ip_str', 'port', 'hostnames', 'location', 'org', 'product', 'os', 'vulns']
            writer = csv.DictWriter(csvfile, fieldnames=fieldnames) # Create a CSV writer object with the fieldnames
            writer.writeheader() # Write the header row with the column names
            
            # Iterate over each result (host)
            for result in results['matches']:
                vulns = ', '.join(result.get('vulns', [])) if result.get('vulns') else 'None' # Get the vulnerabilities list and join them with commas if they exist, otherwise set to 'None'
                # Write a row for each host with relevant details
                writer.writerow({
                    'ip_str': result.get('ip_str'), # Get the IP address
                    'port': result.get('port'), # Get the port number
                    'hostnames': result.get('hostnames'), # Get the hostnames
                    'location': f"{result['location']['city']}, {result['location']['country_name']}", # Get the location
                    'org': result.get('org'), # Get the organization
                    'product': result.get('product'), # Get the product
                    'os': result.get('os'), # Get the operating system
                    'vulns': vulns  # Include vulnerabilities
                })

        # Render the results page with the search results
        return render_template('results.html', results=results['matches'])
    except shodan.APIError as e: # Handle Shodan API errors
        logging.error(f"Shodan API Error: {str(e)}") # Log the error message
        return f"Error: {str(e)}" # Return the error message e contain the error message.
    except Exception as e: # Handle unexpected errors
        logging.error(f"Unexpected Error: {str(e)}") # Log the error message
        return f"Unexpected Error: {str(e)}" # Return the error message e contain the error message.

if __name__ == "__main__": # Check if the script is being run directly
    app.run(host='0.0.0.0', port=4000) # Run the Flask application on host
