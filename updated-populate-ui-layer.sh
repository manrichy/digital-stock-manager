#!/bin/bash

echo "🚀 Populating Infrastructure Layer with Multi-Page Polymorphic UI Views..."

BASE_STATIC="infrastructure/src/main/resources/static"

# Ensure Spring Boot static resource directory exists
mkdir -p "$BASE_STATIC"

# ================================================================
# 1. WRITE UNIFIED NAVIGATION DASHBOARD (index.html)
# ================================================================
echo "📝 Writing index.html..."

cat << 'EOF' > "$BASE_STATIC/index.html"
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Digital Stock Manager - Hexagonal Control Panel</title>
    <style>
        :root {
            --bg-primary: #f8fafc;
            --panel-bg: #ffffff;
            --text-main: #1e293b;
            --brand-color: #2563eb;
            --border-color: #e2e8f0;
        }
        * { box-sizing: border-box; margin: 0; padding: 0; font-family: 'Segoe UI', sans-serif; }
        body { background-color: var(--bg-primary); color: var(--text-main); padding: 30px; }
        header { background: linear-gradient(135deg, #1e3a8a, var(--brand-color)); color: white; padding: 30px; border-radius: 12px; margin-bottom: 30px; }
        .dashboard-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(280px, 1fr)); gap: 20px; margin-top: 20px; }
        .nav-card { background: var(--panel-bg); border: 1px solid var(--border-color); border-radius: 12px; padding: 25px; text-align: center; box-shadow: 0 4px 6px -1px rgba(0,0,0,0.05); transition: transform 0.2s; }
        .nav-card:hover { transform: translateY(-4px); }
        .nav-card h3 { margin-bottom: 10px; color: #0f172a; }
        .nav-card p { font-size: 0.9rem; color: #64748b; margin-bottom: 20px; min-height: 40px; }
        .btn-link { display: inline-block; padding: 10px 20px; background-color: var(--brand-color); color: white; text-decoration: none; border-radius: 6px; font-weight: 600; font-size: 0.9rem; }
        .btn-link:hover { background-color: #1d4ed8; }
    </style>
</head>
<body>

    <header>
        <h1>📦 Digital Stock Manager Workspace</h1>
        <p>Polymorphic Core Engine Viewporter & Layered Execution Environment</p>
    </header>

    <h2>Functional Operation Subsystems</h2>
    <div class="dashboard-grid">
        <div class="nav-card">
            <h3>✨ Product Onboarding</h3>
            <p>Register standard or specialized perishable variants into the domain state registry.</p>
            <a href="onboard.html" class="btn-link">Open Use Case View</a>
        </div>

        <div class="nav-card">
            <h3>📈 Ledger Mutation</h3>
            <p>Commit supply restocks or execute outbound allocation deductions securely.</p>
            <a href="mutate.html" class="btn-link">Open Use Case View</a>
        </div>

        <div class="nav-card">
            <h3>🔍 Live Projections View</h3>
            <p>Read real-time read model queries, low-stock alerts, and expiring product statuses.</p>
            <a href="view-registry.html" class="btn-link">Open Use Case View</a>
        </div>
    </div>

</body>
</html>
EOF

# ================================================================
# 2. WRITE USE CASE PAGE: PRODUCT ONBOARDING (onboard.html)
# ================================================================
echo "📝 Writing onboard.html..."

cat << 'EOF' > "$BASE_STATIC/onboard.html"
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Onboard Product Use Case</title>
    <style>
        :root { --bg: #f8fafc; --brand: #2563eb; --border: #e2e8f0; }
        * { box-sizing: border-box; margin: 0; padding: 0; font-family: sans-serif; }
        body { background: var(--bg); padding: 30px; display: flex; justify-content: center; }
        .container { background: white; max-width: 500px; width: 100%; padding: 30px; border-radius: 12px; box-shadow: 0 4px 10px rgba(0,0,0,0.05); }
        h2 { margin-bottom: 20px; color: #1e3a8a; }
        .form-group { margin-bottom: 15px; }
        label { display: block; font-weight: 600; font-size: 0.85rem; margin-bottom: 5px; color: #475569; }
        .control { width: 100%; padding: 10px; border: 1px solid var(--border); border-radius: 6px; }
        .btn { width: 100%; padding: 12px; background: var(--brand); color: white; border: none; border-radius: 6px; font-weight: bold; cursor: pointer; margin-top: 10px; }
        .back-link { display: inline-block; margin-top: 15px; color: #64748b; text-decoration: none; font-size: 0.9rem; }
    </style>
</head>
<body>

<div class="container">
    <h2>✨ Use Case: Onboard Product</h2>
    <form id="onboardForm">
        <div class="form-group">
            <label for="itemCode">Unique Product SKU</label>
            <input type="text" id="itemCode" class="control" placeholder="e.g., APP-MAC-01" required>
        </div>
        <div class="form-group">
            <label for="itemName">Product Name</label>
            <input type="text" id="itemName" class="control" required>
        </div>
        <div class="form-group">
            <label for="price">Unit Base Price ($)</label>
            <input type="number" id="price" class="control" step="0.01" required>
        </div>
        <div class="form-group">
            <label for="initialQuantity">Starting Quantity</label>
            <input type="number" id="initialQuantity" class="control" value="0">
        </div>
        <div class="form-group">
            <label for="threshold">Low Stock Warning Threshold</label>
            <input type="number" id="threshold" class="control" value="10" required>
        </div>
        <div class="form-group">
            <label for="expiryDate">Expiration Date (Leave blank if non-perishable variant)</label>
            <input type="date" id="expiryDate" class="control">
        </div>
        <button type="submit" class="btn">Dispatch Registration Command</button>
    </form>
    <a href="index.html" class="back-link">← Return to Dashboard Workspace</a>
</div>

<script>
    document.getElementById('onboardForm').addEventListener('submit', async (e) => {
        e.preventDefault();
        const payload = {
            itemCode: document.getElementById('itemCode').value.trim(),
            itemName: document.getElementById('itemName').value.trim(),
            price: parseFloat(document.getElementById('price').value),
            initialQuantity: parseInt(document.getElementById('initialQuantity').value) || 0,
            threshold: parseInt(document.getElementById('threshold').value),
            expiryDate: document.getElementById('expiryDate').value || null
        };
        try {
            const res = await fetch('/api/products', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify(payload)
            });
            alert(res.ok ? "Success: Polymorphic domain state instantiated!" : "Rejected by Core Invariant Logic.");
            if(res.ok) document.getElementById('onboardForm').reset();
        } catch (err) { alert("Network delivery failure."); }
    });
</script>
</body>
</html>
EOF

# ================================================================
# 3. WRITE USE CASE PAGE: LEDGER MUTATOR (mutate.html)
# ================================================================
echo "📝 Writing mutate.html..."

cat << 'EOF' > "$BASE_STATIC/mutate.html"
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Execute Stock Mutation</title>
    <style>
        :root { --bg: #f8fafc; --brand: #475569; --border: #e2e8f0; }
        * { box-sizing: border-box; margin: 0; padding: 0; font-family: sans-serif; }
        body { background: var(--bg); padding: 30px; display: flex; justify-content: center; }
        .container { background: white; max-width: 500px; width: 100%; padding: 30px; border-radius: 12px; box-shadow: 0 4px 10px rgba(0,0,0,0.05); }
        h2 { margin-bottom: 20px; color: #1e293b; }
        .form-group { margin-bottom: 15px; }
        label { display: block; font-weight: 600; font-size: 0.85rem; margin-bottom: 5px; color: #475569; }
        .control { width: 100%; padding: 10px; border: 1px solid var(--border); border-radius: 6px; }
        .btn { width: 100%; padding: 12px; background: var(--brand); color: white; border: none; border-radius: 6px; font-weight: bold; cursor: pointer; margin-top: 10px; }
        .back-link { display: inline-block; margin-top: 15px; color: #64748b; text-decoration: none; font-size: 0.9rem; }
    </style>
</head>
<body>

<div class="container">
    <h2>📈 Use Case: Commit Stock Mutation</h2>
    <form id="mutationForm">
        <div class="form-group">
            <label for="mutateSku">Target Product SKU</label>
            <input type="text" id="mutateSku" class="control" required placeholder="e.g., APP-MAC-01">
        </div>
        <div class="form-group">
            <label for="mutationType">Transaction Context Mapping</label>
            <select id="mutationType" class="control">
                <option value="restock">Batch Supplier Inbound Restock (+)</option>
                <option value="deduct">Order Assignment Outbound Allocation (-)</option>
            </select>
        </div>
        <div class="form-group">
            <label for="mutateAmount">Quantity Magnitude (Delta)</label>
            <input type="number" id="mutateAmount" class="control" min="1" value="1" required>
        </div>
        <button type="submit" class="btn">Execute Transaction Delta</button>
    </form>
    <a href="index.html" class="back-link">← Return to Dashboard Workspace</a>
</div>

<script>
    document.getElementById('mutationForm').addEventListener('submit', async (e) => {
        e.preventDefault();
        const sku = document.getElementById('mutateSku').value.trim();
        const type = document.getElementById('mutationType').value;
        const amount = parseInt(document.getElementById('mutateAmount').value);

        try {
            const res = await fetch(`/api/products/${sku}/${type}`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ amount: amount })
            });
            alert(res.ok ? "Ledger updated and projection balances recalibrated." : "Mutation rejected by domain constraints.");
            if(res.ok) document.getElementById('mutationForm').reset();
        } catch (err) { alert("Network link exception failure."); }
    });
</script>
</body>
</html>
EOF

# ================================================================
# 4. WRITE USE CASE PAGE: VIEW REGISTRY PROJECTIONS (view-registry.html)
# ================================================================
echo "📝 Writing view-registry.html..."

cat << 'EOF' > "$BASE_STATIC/view-registry.html"
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Query Projection Registry Model View</title>
    <style>
        :root { --bg: #f8fafc; --border: #e2e8f0; --brand: #2563eb; }
        * { box-sizing: border-box; margin: 0; padding: 0; font-family: sans-serif; }
        body { background: var(--bg); padding: 30px; }
        .container { background: white; width: 100%; padding: 25px; border-radius: 12px; box-shadow: 0 4px 6px rgba(0,0,0,0.02); }
        h2 { margin-bottom: 20px; color: #0f172a; }
        .filter-tabs { display: flex; gap: 10px; margin-bottom: 20px; }
        .tab { padding: 8px 16px; background: #e2e8f0; border: none; border-radius: 20px; font-weight: bold; cursor: pointer; font-size: 0.85rem; color: #475569; }
        .tab.active { background: var(--brand); color: white; }
        table { width: 100%; border-collapse: collapse; text-align: left; }
        th { background: #f1f5f9; padding: 12px; color: #64748b; border-bottom: 2px solid var(--border); }
        td { padding: 12px; border-bottom: 1px solid var(--border); font-size: 0.95rem; }
        .badge { padding: 4px 8px; border-radius: 12px; font-size: 0.75rem; font-weight: bold; text-transform: uppercase; }
        .badge.active { background: #d1fae5; color: #065f46; }
        .badge.low-stock { background: #fef3c7; color: #92400e; }
        .back-link { display: inline-block; margin-top: 20px; color: #64748b; text-decoration: none; font-size: 0.9rem; }
    </style>
</head>
<body>

<div class="container">
    <h2>🔍 Query Component Model Projections</h2>

    <div class="filter-tabs">
        <button class="tab active" id="btn-all" onclick="fetchProjections('all')">Full Materialized State</button>
        <button class="tab" id="btn-low" onclick="fetchProjections('low')">⚠️ Insufficient Balances</button>
    </div>

    <table id="projectionsTable">
        <thead>
            <tr>
                <th>Item Code</th>
                <th>Product Identifier</th>
                <th>Calculated Pricing</th>
                <th>Available Balance</th>
                <th>Threshold Limit</th>
                <th>Lifespan Terminus</th>
                <th>Status Mapping</th>
            </tr>
        </thead>
        <tbody id="registryBody">
            <tr><td colspan="7" style="text-align:center; color:#94a3b8;">Loading model projections...</td></tr>
        </tbody>
    </table>

    <a href="index.html" class="back-link">← Return to Dashboard Workspace</a>
</div>

<script>
    async function fetchProjections(criteria) {
        document.querySelectorAll('.tab').forEach(t => t.classList.remove('active'));
        document.getElementById(`btn-${criteria}`).classList.add('active');

        let url = '/api/products';
        if (criteria === 'low') url += '/alerts/low-stock';
        else url += '/search?q=';

        try {
            const res = await fetch(url);
            const items = await res.json();
            const body = document.getElementById('registryBody');

            if (!items || items.length === 0) {
                body.innerHTML = `<tr><td colspan="7" style="text-align:center; color:#94a3b8; padding:20px;">No projections matching criteria constraints found.</td></tr>`;
                return;
            }

            body.innerHTML = items.map(item => {
                const isLow = item.quantity <= item.threshold;
                return `
                    <tr>
                        <td><strong>${item.itemCode}</strong></td>
                        <td>${item.itemName}</td>
                        <td>$${item.price.toFixed(2)}</td>
                        <td><span class="badge ${isLow ? 'low-stock' : 'active'}">${item.quantity}</span></td>
                        <td>${item.threshold}</td>
                        <td>${item.expiryDate || '—'}</td>
                        <td><span class="badge active">${item.status}</span></td>
                    </tr>
                `;
            }).join('');
        } catch (err) {
            document.getElementById('registryBody').innerHTML = `<tr><td colspan="7" style="text-align:center; color:red; padding:20px;">Failure querying pipeline infrastructure.</td></tr>`;
        }
    }
    document.addEventListener('DOMContentLoaded', () => fetchProjections('all'));
</script>
</body>
</html>
EOF

echo "✨ Multi-page architecture view generation phase finalized successfully!"