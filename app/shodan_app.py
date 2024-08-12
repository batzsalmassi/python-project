from flask import Flask, request, render_template # Import the Flask class from the flask module
import shodan # Import the Shodan library
import logging # Import the logging module
import os # Import the OS module
import csv # Import the CSV module

app = Flask(__name__) # Create an instance of the Flask class with the name of the running application as the argument

# Load the Shodan API key from environment variables
SHODAN_API_KEY = os.getenv('SHODAN_API_KEY')

# Ensure the API key is available
if not SHODAN_API_KEY:
    raise ValueError("No SHODAN_API_KEY found in environment variables.") # Raise a ValueError if the SHODAN_API_KEY is not found

api = shodan.Shodan(SHODAN_API_KEY) # Create an instance of the Shodan class with the API key as the argument to authenticate the API

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
    ip = request.form.get('ip')
    try:
        logging.debug(f"Searching for IP: {ip}")
        results = api.host(ip)
        logging.debug(f"Results: {results}")
        # Save the results to a JSON file
        
        return render_template('host_results.html', results=results)
    except shodan.APIError as e:
        logging.error(f"Shodan API Error: {str(e)}")
        return f"Error: {str(e)}"
    except Exception as e:
        logging.error(f"Unexpected Error: {str(e)}")
        return f"Unexpected Error: {str(e)}"

@app.route('/perform_filter_search', methods=['POST'])
def perform_filter_search():
    port = request.form.get('port')
    country = request.form.get('country')
    product = request.form.get('product')
    os = request.form.get('os')
    category = request.form.get('category')


    filters = []
    if port:
        filters.append(f'port:{port}')
    if country:
        filters.append(f'country:{country}')
    if product:
        filters.append(f'product:{product}')
    if os:
        filters.append(f'os:{os}')
    if category:
        filters.append(f'category:{category}')
    
    query = ' '.join(filters)
    print ("This is the filters ",  filters)
    
    try:
        logging.debug(f"Searching with query: {query}")
        results = api.search(query)
        # Save the results to a CSV file 'a' is for append mode to add new results to the existing file
        with open('shodan_results.csv', 'a', newline='') as csvfile:
            # Define the CSV column headers
            fieldnames = ['ip_str', 'port', 'hostnames', 'location', 'org', 'product', 'os', 'vulns']
            writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
            
            
            # Write the header row
            writer.writeheader()
            
            # Iterate over each result (host)
            for result in results['matches']:
                # Prepare the vulnerabilities list (if any) as a comma-separated string
                vulns = ', '.join(result.get('vulns', [])) if result.get('vulns') else 'None'

                # Write a row for each host with relevant details
                writer.writerow({
                    'ip_str': result.get('ip_str'),
                    'port': result.get('port'),
                    'hostnames': result.get('hostnames'),
                    'location': f"{result['location']['city']}, {result['location']['country_name']}",
                    'org': result.get('org'),
                    'product': result.get('product'),
                    'os': result.get('os'),
                    'vulns': vulns  # Include vulnerabilities
                })

        # Render the results page with the search results
        return render_template('results.html', results=results['matches'])
    except shodan.APIError as e:
        logging.error(f"Shodan API Error: {str(e)}")
        return f"Error: {str(e)}"
    except Exception as e:
        logging.error(f"Unexpected Error: {str(e)}")
        return f"Unexpected Error: {str(e)}"

if __name__ == "__main__":
    app.run(host='0.0.0.0', port=5000)
