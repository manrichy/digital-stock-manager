#!/bin/bash

echo "🚀 Populating Infrastructure Layer with a Unified Dashboard UI..."

BASE_STATIC="infrastructure/src/main/resources/static"

# Ensure Spring Boot static resource directory exists
mkdir -p "$BASE_STATIC"

# ----------------------------------------------------------------
# 📱 WRITE COMPLETE WEB DASHBOARD (index.html)
# ----------------------------------------------------------------
echo "📝 Writing index.html..."

cat << 'EOF' > "$BASE_STATIC/index.html"
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Digital Stock Manager - CQRS Inventory Panel</title>
    <style>
        :root {
            --bg-primary: #f8fafc;
            --panel-bg: #ffffff;
            --text-main: #1e293b;
            --brand-color: #2563eb;
            --brand-hover: #1d4ed8;
            --accent-success: #10b981;
            --accent-warn: #f59e0b;
            --accent-danger: #ef4444;
            --border-color: #e2e8f0;
        }

        * { box-sizing: border-box; margin: 0; padding: 0; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; }
        body { background-color: var(--bg-primary); color: var(--text-main); line-height: 1.6; padding: 20px; }
        header { background: linear-gradient(135deg, #1e3a8a, var(--brand-color)); color: white; padding: 20px; border-radius: 12px; margin-bottom: 25px; box-shadow: 0 4px 6px -1px rgba(0,0,0,0.1); }
        header h1 { font-size: 1.8rem; margin-bottom: 5px; }

        .toast { position: fixed; top: 20px; right: 20px; padding: 15px 25px; border-radius: 8px; color: white; font-weight: 600; display: none; z-index: 1000; box-shadow: 0 10px 15px -3px rgba(0,0,0,0.1); }
        .toast.success { background-color: var(--accent-success); }
        .toast.error { background-color: var(--accent-danger); }

        .grid-container { display: grid; grid-template-columns: 1fr 2fr; gap: 25px; }
        @media(max-width: 1024px) { .grid-container { grid-template-columns: 1fr; } }

        .card { background-color: var(--panel-bg); border: 1px solid var(--border-color); border-radius: 12px; padding: 20px; box-shadow: 0 1px 3px rgba(0,0,0,0.05); margin-bottom: 25px; }
        .card h2 { font-size: 1.2rem; margin-bottom: 15px; border-bottom: 2px solid var(--bg-primary); padding-bottom: 8px; display: flex; justify-content: space-between; align-items: center; }

        .form-group { margin-bottom: 15px; }
        .form-group label { display: block; font-size: 0.85rem; font-weight: 600; margin-bottom: 5px; color: #64748b; }
        .form-control { width: 100%; padding: 10px; border: 1px solid var(--border-color); border-radius: 6px; font-size: 0.95rem; transition: border 0.2s; }
        .form-control:focus { outline: none; border-color: var(--brand-color); }

        .btn { display: inline-block; width: 100%; padding: 12px; background-color: var(--brand-color); color: white; border: none; border-radius: 6px; font-weight: 600; font-size: 0.95rem; cursor: pointer; transition: background 0.2s; text-align: center; }
        .btn:hover { background-color: var(--brand-hover); }
        .btn-secondary { background-color: #64748b; }
        .btn-secondary:hover { background-color: #475569; }

        .search-box { display: flex; gap: 10px; margin-bottom: 15px; }
        .search-box .form-control { flex: 1; }
        .search-box .btn { width: auto; padding: 0 20px; }

        .filter-tabs { display: flex; gap: 10px; margin-bottom: 15px; overflow-x: auto; padding-bottom: 5px; }
        .tab-btn { padding: 8px 16px; background-color: #e2e8f0; border: none; border-radius: 20px; font-size: 0.85rem; font-weight: 600; cursor: pointer; color: #475569; whitespace: nowrap; }
        .tab-btn.active { background-color: var(--brand-color); color: white; }

        .table-responsive { width: 100%; overflow-x: auto; }
        table { width: 100%; border-collapse: collapse; text-align: left; font-size: 0.9rem; }
        th { background-color: var(--bg-primary); padding: 12px; font-weight: 600; color: #64748b; border-bottom: 2px solid var(--border-color); }
        td { padding: 12px; border-bottom: 1px solid var(--border-color); vertical-align: middle; }
        tr:hover { background-color: #f8fafc; }

        .badge { display: inline-block; padding: 4px 8px; border-radius: 12px; font-size: 0.75rem; font-weight: 700; text-transform: uppercase; }
        .badge.active { background-color: #d1fae5; color: #065f46; }
        .badge.discontinued { background-color: #fee2e2; color: #991b1b; }
        .badge.low-stock { background-color: #fef3c7; color: #92400e; }

        .action-inline-group { display: flex; gap: 5px; }
        .btn-sm { padding: 6px 10px; font-size: 0.8rem; width: auto; border-radius: 4px; }
        .btn-danger { background-color: var(--accent-danger); }
        .btn-danger:hover { background-color: #dc2626; }
        .btn-success { background-color: var(--accent-success); }
        .btn-success:hover { background-color: #059669; }
    </style>
</head>
<body>

    <div id="toastNotification" class="toast"></div>

    <header>
        <h1>📦 Digital Stock Manager Dashboard</h1>
        <p>CQRS Engine State & Hexagonal Flow Controller Interface</p>
    </header>

    <div class="grid-container">
        <!-- LEFT COLUMN: COMMAND STATE MUTATIONS -->
        <div>
            <!-- FORM 1: ONBOARD PRODUCT -->
            <div class="card">
                <h2 id="formTitle">Onboard New Product</h2>
                <form id="productForm">
                    <input type="hidden" id="formMode" value="CREATE">
                    <div class="form-group" id="skuContainer">
                        <label for="itemCode">Unique Item SKU / Code</label>
                        <input type="text" id="itemCode" class="form-control" placeholder="e.g., MOUSE-WRL-100" required>
                    </div>
                    <div class="form-group">
                        <label for="itemName">Product Name</label>
                        <input type="text" id="itemName" class="form-control" placeholder="e.g., Logi Wireless Mouse" required>
                    </div>
                    <div class="form-group">
                        <label for="price">Unit Base Price ($)</label>
                        <input type="number" id="price" class="form-control" step="0.01" min="0" placeholder="0.00" required>
                    </div>
                    <div class="form-group" id="initialQtyContainer">
                        <label for="initialQuantity">Initial Starting Quantity</label>
                        <input type="number" id="initialQuantity" class="form-control" min="0" placeholder="0">
                    </div>
                    <div class="form-group">
                        <label for="threshold">Safety Low-Stock Threshold</label>
                        <input type="number" id="threshold" class="form-control" min="0" placeholder="10" required>
                    </div>
                    <div class="form-group" id="expiryContainer">
                        <label for="expiryDate">Expiration Date (Optional)</label>
                        <input type="date" id="expiryDate" class="form-control">
                    </div>
                    <div style="display:flex; gap:10px;">
                        <button type="submit" id="submitBtn" class="btn">Execute Onboard Command</button>
                        <button type="button" id="cancelEditBtn" class="btn btn-secondary btn-sm" style="display:none;" onclick="resetFormState()">Cancel</button>
                    </div>
                </form>
            </div>

            <!-- FORM 2: QUICK INVENTORY MUTATOR (RESTOCK / DEDUCT) -->
            <div class="card">
                <h2>Quick Stock Ledger Mutation</h2>
                <form id="mutationForm">
                    <div class="form-group">
                        <label for="mutateSku">Target Product SKU</label>
                        <input type="text" id="mutateSku" class="form-control" placeholder="e.g., MOUSE-WRL-100" required>
                    </div>
                    <div class="form-group">
                        <label for="mutationType">Transaction Action Type</label>
                        <select id="mutationType" class="form-control">
                            <option value="restock">Batch Supplier Restock (+)</option>
                            <option value="deduct">Order Allocation Fulfillment (-)</option>
                        </select>
                    </div>
                    <div class="form-group">
                        <label for="mutateAmount">Unit Quantity Delta</label>
                        <input type="number" id="mutateAmount" class="form-control" min="1" placeholder="1" required>
                    </div>
                    <button type="submit" class="btn btn-secondary">Commit Mutation Request</button>
                </form>
            </div>
        </div>

        <!-- RIGHT COLUMN: QUERY PROJECTIONS READ MODEL -->
        <div>
            <div class="card">
                <h2>Live Materialized Inventory View</h2>

                <!-- Query Filter Search Bar -->
                <div class="search-box">
                    <input type="text" id="searchQuery" class="form-control" placeholder="Search items by keyword or strict SKU...">
                    <button type="button" class="btn" onclick="triggerSearch()">Search Catalog</button>
                </div>

                <!-- Functional Filter Projections -->
                <div class="filter-tabs">
                    <button class="tab-btn active" id="tab-all" onclick="loadQueryData('all')">Full Registry View</button>
                    <button class="tab-btn" id="tab-low" onclick="loadQueryData('low')">⚠️ Low Stock Alerts</button>
                    <button class="tab-btn" id="tab-expiring" onclick="loadQueryData('expiring')">⏳ Near Expiry (7 Days)</button>
                </div>

                <!-- Live Projection Grid Output -->
                <div class="table-responsive">
                    <table>
                        <thead>
                            <tr>
                                <th>SKU / Code</th>
                                <th>Product Name</th>
                                <th>Price</th>
                                <th>Stock</th>
                                <th>Threshold</th>
                                <th>Expiry</th>
                                <th>Status</th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody id="inventoryGrid">
                            <tr>
                                <td colspan="8" style="text-align:center; color:#94a3b8; padding:30px;">Loading live engine query model state views...</td>
                            </tr>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>

    <script>
        const API_BASE = '/api/products';

        // Helper notification banner pipeline
        function notify(msg, isError = false) {
            const toast = document.getElementById('toastNotification');
            toast.innerText = msg;
            toast.className = `toast ${isError ? 'error' : 'success'}`;
            toast.style.display = 'block';
            setTimeout(() => { toast.style.display = 'none'; }, 4000);
        }

        // Initialize and load UI state
        document.addEventListener('DOMContentLoaded', () => {
            loadQueryData('all');

            // Hook Event Listener on Product Write Form Submission
            document.getElementById('productForm').addEventListener('submit', function(e) {
                e.preventDefault();
                executeProductCommand();
            });

            // Hook Event Listener on Quantity Mutation Form Submission
            document.getElementById('mutationForm').addEventListener('submit', function(e) {
                e.preventDefault();
                executeMutationCommand();
            });
        });

        // RE-FETCH DATA VIA CQRS QUERY ENDPOINTS
        async function loadQueryData(mode) {
            // Adjust active tab css
            document.querySelectorAll('.filter-tabs .tab-btn').forEach(btn => btn.classList.remove('active'));
            document.getElementById(`tab-${mode}`).classList.add('active');

            let url = API_BASE;
            if (mode === 'low') url += '/alerts/low-stock';
            else if (mode === 'expiring') url += '/alerts/expiring?days=7';
            else url += '/search?q='; // empty query gets everything via our custom criteria match query fallback

            try {
                const response = await fetch(url);
                const data = await response.json();
                renderGrid(data);
            } catch (err) {
                renderGridError();
            }
        }

        async function triggerSearch() {
            const query = document.getElementById('searchQuery').value.trim();
            try {
                const response = await fetch(`${API_BASE}/search?q=${encodeURIComponent(query)}`);
                const data = await response.json();
                renderGrid(data);
            } catch (err) {
                notify("Failed to execute search execution matrix queries.", true);
            }
        }

        function renderGrid(items) {
            const grid = document.getElementById('inventoryGrid');
            if(!items || items.length === 0) {
                grid.innerHTML = `<tr><td colspan="8" style="text-align:center; color:#94a3b8; padding:30px;">No inventory records match the selected query state mapping profile.</td></tr>`;
                return;
            }

            grid.innerHTML = items.map(item => {
                const isLow = item.status === 'ACTIVE' && item.quantity <= item.threshold;
                return `
                    <tr>
                        <td><strong>${item.itemCode}</strong></td>
                        <td>${item.itemName}</td>
                        <td>$${item.price.toFixed(2)}</td>
                        <td>
                            <span class="badge ${isLow ? 'low-stock' : ''}" style="font-size:0.9rem; padding: 2px 6px;">
                                ${item.quantity}
                            </span>
                        </td>
                        <td>${item.threshold}</td>
                        <td>${item.expiryDate ? item.expiryDate : '<span style="color:#cbd5e1">—</span>'}</td>
                        <td>
                            <span class="badge ${item.status.toLowerCase()}">${item.status}</span>
                        </td>
                        <td>
                            <div class="action-inline-group">
                                <button class="btn btn-sm btn-success" onclick="prepareEdit('${item.itemCode}', '${item.itemName.replace(/'/g, "\\'")}', ${item.price}, ${item.threshold})">Edit</button>
                                ${item.status === 'ACTIVE' ? `<button class="btn btn-sm btn-danger" onclick="executeDiscontinue('${item.itemCode}')">Retire</button>` : ''}
                            </div>
                        </td>
                    </tr>
                `;
            }).join('');
        }

        function renderGridError() {
            document.getElementById('inventoryGrid').innerHTML = `
                <tr><td colspan="8" style="text-align:center; color:var(--accent-danger); padding:30px; font-weight:600;">
                    ⚠️ Error linking data pipeline adapters. Ensure DigitalStockManagerApplication is running live on port 8080.
                </td></tr>`;
        }

        // FIRE COMMAND MUTATIONS
        async function executeProductCommand() {
            const mode = document.getElementById('formMode').value;
            const sku = document.getElementById('itemCode').value.trim();

            const payload = {
                itemName: document.getElementById('itemName').value.trim(),
                price: parseFloat(document.getElementById('price').value),
                threshold: parseInt(document.getElementById('threshold').value)
            };

            let url = API_BASE;
            let method = 'POST';

            if (mode === 'CREATE') {
                payload.itemCode = sku;
                payload.initialQuantity = parseInt(document.getElementById('initialQuantity').value) || 0;
                const expiry = document.getElementById('expiryDate').value;
                payload.expiryDate = expiry ? expiry : null;
            } else {
                url += `/${sku}`;
                method = 'PUT';
            }

            try {
                const response = await fetch(url, {
                    method: method,
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify(payload)
                });
                const result = await response.json();

                if (response.ok) {
                    notify(result.message || "Command executed successfully!");
                    resetFormState();
                    loadQueryData('all');
                } else {
                    notify(result.error || "A domain structural invariant rejected the operation.", true);
                }
            } catch (err) {
                notify("Network link error occurred.", true);
            }
        }

        async function executeMutationCommand() {
            const sku = document.getElementById('mutateSku').value.trim();
            const action = document.getElementById('mutationType').value;
            const amount = parseInt(document.getElementById('mutateAmount').value);

            try {
                const response = await fetch(`${API_BASE}/${sku}/${action}`, {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({ amount: amount })
                });
                const result = await response.json();

                if(response.ok) {
                    notify(result.message);
                    document.getElementById('mutationForm').reset();
                    loadQueryData('all');
                } else {
                    notify(result.error || "Mutation rejected by validation engine layer.", true);
                }
            } catch (err) {
                notify("Network transmission exception failure.", true);
            }
        }

        async function executeDiscontinue(sku) {
            if(!confirm(`Are you absolutely sure you want to completely retire and discontinue product profile [${sku}]? This is an irreversible core state structural transition step.`)) return;

            try {
                const response = await fetch(`${API_BASE}/${sku}`, { method: 'DELETE' });
                const result = await response.json();

                if(response.ok) {
                    notify(result.message);
                    loadQueryData('all');
                } else {
                    notify(result.error, true);
                }
            } catch (err) {
                notify("Network link error occurred.", true);
            }
        }

        // CONTROL UI DOM STATE TRANSITIONS
        function prepareEdit(sku, name, price, threshold) {
            document.getElementById('formTitle').innerText = `Update Details for [${sku}]`;
            document.getElementById('formMode').value = 'EDIT';

            const skuInput = document.getElementById('itemCode');
            skuInput.value = sku;
            document.getElementById('skuContainer').style.display = 'none';

            document.getElementById('itemName').value = name;
            document.getElementById('price').value = price;
            document.getElementById('threshold').value = threshold;

            document.getElementById('initialQtyContainer').style.display = 'none';
            document.getElementById('expiryContainer').style.display = 'none';

            document.getElementById('submitBtn').innerText = "Execute Update Details Command";
            document.getElementById('cancelEditBtn').style.display = 'block';
            window.scrollTo({ top: 0, behavior: 'smooth' });
        }

        function resetFormState() {
            document.getElementById('productForm').reset();
            document.getElementById('formTitle').innerText = "Onboard New Product";
            document.getElementById('formMode').value = 'CREATE';
            document.getElementById('skuContainer').style.display = 'block';
            document.getElementById('initialQtyContainer').style.display = 'block';
            document.getElementById('expiryContainer').style.display = 'block';
            document.getElementById('submitBtn').innerText = "Execute Onboard Command";
            document.getElementById('cancelEditBtn').style.display = 'none';
        }
    </script>
</body>
</html>
EOF

echo "✨ UI Application view built and attached inside static resource directory!"