from flask import Flask, render_template, request, redirect, url_for, flash
import mysql.connector
from dotenv import load_dotenv
import os
from decimal import Decimal

# Load environment variables
load_dotenv()

app = Flask(__name__)
app.secret_key = os.getenv("SECRET_KEY")

if not app.secret_key:
    raise RuntimeError("No SECRET_KEY found in environment variables. Please set it in .env.")

# Connect to the database
try:
    db = mysql.connector.connect(
        host=os.getenv("DB_HOST"),
        user=os.getenv("DB_USER"),
        password=os.getenv("DB_PASSWORD"),
        database=os.getenv("DB_NAME")
    )
    cursor = db.cursor()
except mysql.connector.Error as err:
    print(f"Database connection failed: {err}")
    exit(1)

@app.route('/')
def home():
    return render_template('index.html')

@app.route('/create_account', methods=['GET', 'POST'])
def create_account():
    if request.method == 'POST':
        customer_id = request.form['customer_id']
        branch_id = request.form['branch_id']
        account_type = request.form['account_type']
        initial_balance = float(request.form.get('initial_balance', 0.00))
        date_opened = request.form['date_opened']
        is_new_customer = request.form.get('is_new_customer') == 'on'  # Checkbox value

        try:
            if is_new_customer:
                # Collect new customer details
                first_name = request.form['first_name']
                last_name = request.form['last_name']
                email = request.form['email']

                # Insert new customer
                cursor.execute("""
                    INSERT INTO Customer (first_name, last_name, email)
                    VALUES (%s, %s, %s)
                """, (first_name, last_name, email))
                db.commit()
                customer_id = cursor.lastrowid  # Get the new customer_id
            else:
                # Check if customer_id exists
                cursor.execute("SELECT customer_id FROM Customer WHERE customer_id = %s", (customer_id,))
                if not cursor.fetchone():
                    flash("Customer ID does not exist")
                    return redirect(url_for('create_account'))

            # Check if branch_id exists
            cursor.execute("SELECT branch_id FROM Branch WHERE branch_id = %s", (branch_id,))
            if not cursor.fetchone():
                flash("Branch ID does not exist")
                return redirect(url_for('create_account'))

            # Insert new account
            cursor.execute("""
                INSERT INTO Account (customer_id, branch_id, account_type, balance, date_opened)
                VALUES (%s, %s, %s, %s, %s)
            """, (customer_id, branch_id, account_type, initial_balance, date_opened))
            db.commit()

            flash(f"Account created successfully! Account ID: {cursor.lastrowid}")
            return redirect(url_for('home'))

        except mysql.connector.Error as err:
            flash(f"Error creating account: {err}")
            return redirect(url_for('create_account'))
    
    return render_template('create_account.html')

@app.route('/balance', methods=['POST'])
def check_balance():
    account_id = request.form['account_id']
    cursor.execute("SELECT balance FROM Account WHERE account_id = %s", (account_id,))
    balance = cursor.fetchone()
    if balance:
        return render_template('balance.html', balance=float(balance[0]), account_id=account_id)
    else:
        flash("Account not found")
        return redirect(url_for('home'))

@app.route('/transaction', methods=['POST'])
def process_transaction():
    account_id = request.form['account_id']
    transaction_type = request.form['transaction_type']
    amount = float(request.form['amount'])

    cursor.execute("SELECT balance FROM Account WHERE account_id = %s", (account_id,))
    account = cursor.fetchone()
    if not account:
        flash("Account not found")
        return redirect(url_for('home'))

    current_balance = float(account[0])

    if transaction_type == 'Deposit':
        new_balance = current_balance + amount
    elif transaction_type == 'Withdrawal':
        if current_balance >= amount:
            new_balance = current_balance - amount
        else:
            flash("Insufficient funds for withdrawal")
            return redirect(url_for('home'))
    elif transaction_type == 'Transfer':
        target_account_id = request.form['target_account_id']
        cursor.execute("SELECT balance FROM Account WHERE account_id = %s", (target_account_id,))
        target_account = cursor.fetchone()
        if not target_account:
            flash("Target account not found")
            return redirect(url_for('home'))
        target_balance = float(target_account[0])
        if current_balance >= amount:
            new_balance = current_balance - amount
            target_new_balance = target_balance + amount
            cursor.execute("UPDATE Account SET balance = %s WHERE account_id = %s", 
                          (target_new_balance, target_account_id))
        else:
            flash("Insufficient funds for transfer")
            return redirect(url_for('home'))
    else:
        flash("Invalid transaction type")
        return redirect(url_for('home'))

    cursor.execute("UPDATE Account SET balance = %s WHERE account_id = %s", 
                  (new_balance, account_id))

    cursor.execute("""
        INSERT INTO Transaction (account_id, transaction_type, amount, description) 
        VALUES (%s, %s, %s, %s)
    """, (account_id, transaction_type, amount, f"{transaction_type} of {amount}"))

    db.commit()

    flash(f"{transaction_type} of {amount} successful! New balance: {new_balance}")
    return redirect(url_for('home'))

if __name__ == '__main__':
    app.run(debug=True)