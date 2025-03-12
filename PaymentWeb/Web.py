import random
from flask import Flask, render_template, jsonify, request
from payos import PaymentData, PayOS
import sys
sys.stdout.reconfigure(encoding='utf-8')

# Initialize PayOS
payOS_client = PayOS(
    client_id="067ccc57-2ca4-49f1-9431-7f885699d693",
    api_key="72b3bbb8-8065-4770-86be-6945c5a09503",
    checksum_key="8fe637cec94ef60623b5143f486457dc1a8b55a68e329fb7b815dc014421b4c7"
)

app = Flask(__name__, static_folder="static", template_folder="Web")

# Sample menu items
MENU_ITEMS = [
    {
        "name": "Sigma",
        "description": "Sigma power!!!!",
        "price": 2000,
        "image": "Sigma.jpg"
    },
    {
        "name": "Nigga",
        "description": "Hark work!!!!",
        "price": 2000,
        "image": "Worker.jpg"
    },
    {
        "name": "Lam thue azota",
        "description": "Yommy",
        "price": 40000,
        "image": "azota.png"
    },
]


@app.route('/')
def home():
    return render_template('index.html', menu=MENU_ITEMS)

@app.route('/checkout')
def checkout():
    product = request.args.get('product', 'Product')
    description = request.args.get('description', 'Description')
    price = request.args.get('price', 10000)
    try:
        price = int(price)
    except ValueError:
        price = 10000
    return render_template('checkout.html', product=product, description=description, price=price)

@app.route('/create_payment_link', methods=['POST'])
def create_payment_link():
    try:
        data = request.get_json()
        print("✅ Received request data:", data)

        product = data.get('product', 'Product')
        description = data.get('description', 'Description')[:25]  # Limit to 25 characters
        price = data.get('price', 10000)

        try:
            price = int(price)
        except ValueError:
            print("❌ Invalid price:", price)
            return jsonify(error="Invalid price"), 400  

        domain = "http://127.0.0.1:5500"

        full_description = f"san pham {product} {price}"

        paymentData = PaymentData(
            orderCode=random.randint(1000, 99999),
            amount=price,
            description=full_description,  # Now max 25 characters
            cancelUrl=f"{domain}/cancel",
            returnUrl=f"{domain}/success"
        )

        payosCreatePayment = payOS_client.createPaymentLink(paymentData)
        payment_url = payosCreatePayment.checkoutUrl  

        if not payment_url:
            raise Exception("❌ Payment URL not found in response.")

        print("✅ Generated Payment URL:", payment_url)
        return jsonify(checkoutUrl=payment_url)

    except Exception as e:
        print("🚨 Error in create_payment_link:", str(e))
        return jsonify(error=str(e)), 403  

@app.route('/success')
def success():
    return render_template('success.html')

@app.route('/cancel')
def cancel():
    return render_template('cancel.html')

if __name__ == '__main__':
    app.run(debug=True, port=5500)
