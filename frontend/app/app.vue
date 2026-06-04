<template>
  <div class="app-container">
    <!-- Ambient Background Glows -->
    <div class="glow-bg-1"></div>
    <div class="glow-bg-2"></div>

    <header class="app-header">
      <div class="header-content">
        <h1 class="brand-title">Aetheria</h1>
        <p class="brand-subtitle">Premium Product Catalog & Management System</p>
      </div>
      <button class="btn btn-primary btn-add" @click="openAddModal">
        <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="12" y1="5" x2="12" y2="19"></line><line x1="5" y1="12" x2="19" y2="12"></line></svg>
        <span>Add Product</span>
      </button>
    </header>

    <!-- Controls (Search) -->
    <section class="controls-section">
      <div class="search-wrapper">
        <svg class="search-icon" xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="11" cy="11" r="8"></circle><line x1="21" y1="21" x2="16.65" y2="16.65"></line></svg>
        <input 
          id="search-input"
          type="text" 
          v-model="searchQuery" 
          placeholder="Search products by name or description..." 
          class="search-input"
          autocomplete="off"
        />
        <button v-if="searchQuery" class="clear-search-btn" @click="searchQuery = ''">
          <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="18" y1="6" x2="6" y2="18"></line><line x1="6" y1="6" x2="18" y2="18"></line></svg>
        </button>
      </div>
    </section>

    <!-- Product Grid & Loading States -->
    <main class="catalog-section">
      <!-- Loading Skeleton Grid -->
      <div v-if="isLoading" class="product-grid">
        <div v-for="n in 8" :key="'skeleton-' + n" class="product-card skeleton-card">
          <div class="skeleton skeleton-title"></div>
          <div class="skeleton skeleton-text-1"></div>
          <div class="skeleton skeleton-text-2"></div>
          <div class="card-footer">
            <div class="skeleton skeleton-price"></div>
            <div class="skeleton skeleton-btn"></div>
          </div>
        </div>
      </div>

      <!-- Empty State -->
      <div v-else-if="products.length === 0" class="empty-state-card">
        <div class="empty-icon-wrapper">
          <svg xmlns="http://www.w3.org/2000/svg" width="48" height="48" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"><path d="M21 16V8a2 2 0 0 0-1-1.73l-7-4a2 2 0 0 0-2 0l-7 4A2 2 0 0 0 3 8v8a2 2 0 0 0 1 1.73l7 4a2 2 0 0 0 2 0l7-4A2 2 0 0 0 21 16z"></path><polyline points="3.27 6.96 12 12.01 20.73 6.96"></polyline><line x1="12" y1="22.08" x2="12" y2="12"></line></svg>
        </div>
        <h3>No Products Found</h3>
        <p>We couldn't find any products matching your search term or catalog database is empty.</p>
        <button v-if="searchQuery" class="btn btn-secondary" @click="searchQuery = ''">Clear Search</button>
        <button v-else class="btn btn-primary" @click="openAddModal">Add Your First Product</button>
      </div>

      <!-- Active Grid -->
      <div v-else class="product-grid">
        <div 
          v-for="product in products" 
          :key="product.id" 
          class="product-card"
          @click="openDetailModal(product)"
        >
          <div class="card-body">
            <h3 class="product-name">{{ product.name }}</h3>
            <p class="product-description">{{ truncateText(product.description, 120) }}</p>
          </div>
          <div class="card-footer">
            <span class="product-price">${{ formatPrice(product.price) }}</span>
            <button class="btn btn-details" @click.stop="openDetailModal(product)">
              <span>View Details</span>
              <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="5" y1="12" x2="19" y2="12"></line><polyline points="12 5 19 12 12 19"></polyline></svg>
            </button>
          </div>
        </div>
      </div>
    </main>

    <!-- Pagination Controls -->
    <footer v-if="!isLoading && products.length > 0" class="pagination-section">
      <div class="pagination-info">
        Showing Page <span class="highlight">{{ currentPage }}</span> of <span class="highlight">{{ totalPages }}</span> ({{ totalProducts }} total products)
      </div>
      <div class="pagination-controls">
        <button 
          id="prev-page-btn"
          class="btn btn-pagination" 
          :disabled="currentPage === 1" 
          @click="currentPage--"
        >
          <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="15 18 9 12 15 6"></polyline></svg>
          <span>Prev</span>
        </button>

        <div class="page-numbers">
          <button 
            v-for="page in totalPages" 
            :key="page" 
            class="page-number-btn"
            :class="{ active: page === currentPage }"
            @click="currentPage = page"
          >
            {{ page }}
          </button>
        </div>

        <button 
          id="next-page-btn"
          class="btn btn-pagination" 
          :disabled="currentPage === totalPages" 
          @click="currentPage++"
        >
          <span>Next</span>
          <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="9 18 15 12 9 6"></polyline></svg>
        </button>
      </div>
    </footer>

    <!-- ADD PRODUCT MODAL -->
    <Transition name="fade">
      <div v-if="showAddModal" class="modal-overlay" @click.self="closeAddModal">
        <Transition name="zoom">
          <div class="modal-content glass-panel" role="dialog" aria-modal="true">
            <header class="modal-header">
              <h3>Create New Product</h3>
              <button class="close-modal-btn" @click="closeAddModal">
                <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="18" y1="6" x2="6" y2="18"></line><line x1="6" y1="6" x2="18" y2="18"></line></svg>
              </button>
            </header>

            <form class="modal-form" @submit.prevent="submitProduct">
              <div class="form-group">
                <label for="product-name">Product Name</label>
                <input 
                  id="product-name"
                  type="text" 
                  v-model="newProduct.name" 
                  placeholder="e.g. Mechanical Keyboard G-800" 
                  class="form-control"
                  :class="{ 'is-invalid': formErrors.name }"
                />
                <span v-if="formErrors.name" class="error-msg">{{ formErrors.name }}</span>
              </div>

              <div class="form-group">
                <label for="product-price">Price ($ USD)</label>
                <input 
                  id="product-price"
                  type="number" 
                  step="0.01"
                  v-model.number="newProduct.price" 
                  placeholder="0.00" 
                  class="form-control"
                  :class="{ 'is-invalid': formErrors.price }"
                />
                <span v-if="formErrors.price" class="error-msg">{{ formErrors.price }}</span>
              </div>

              <div class="form-group">
                <label for="product-desc">Description</label>
                <textarea 
                  id="product-desc"
                  rows="4" 
                  v-model="newProduct.description" 
                  placeholder="Describe the product features, specifications, and materials..." 
                  class="form-control text-area"
                  :class="{ 'is-invalid': formErrors.description }"
                ></textarea>
                <span v-if="formErrors.description" class="error-msg">{{ formErrors.description }}</span>
              </div>

              <div class="modal-actions">
                <button type="button" class="btn btn-secondary" @click="closeAddModal">Cancel</button>
                <button type="submit" class="btn btn-primary" :disabled="isSubmitting">
                  <span v-if="isSubmitting" class="spinner"></span>
                  <span>{{ isSubmitting ? 'Creating...' : 'Create Product' }}</span>
                </button>
              </div>
            </form>
          </div>
        </Transition>
      </div>
    </Transition>

    <!-- PRODUCT DETAIL MODAL -->
    <Transition name="fade">
      <div v-if="showDetailModal && selectedProduct" class="modal-overlay" @click.self="closeDetailModal">
        <Transition name="zoom">
          <div class="modal-content detail-modal glass-panel" role="dialog" aria-modal="true">
            <header class="modal-header">
              <h3>Product Specifications</h3>
              <button class="close-modal-btn" @click="closeDetailModal">
                <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="18" y1="6" x2="6" y2="18"></line><line x1="6" y1="6" x2="18" y2="18"></line></svg>
              </button>
            </header>

            <div class="modal-body detail-body">
              <h2 class="detail-name">{{ selectedProduct.name }}</h2>
              <div class="detail-price-badge">${{ formatPrice(selectedProduct.price) }}</div>
              
              <div class="detail-section">
                <h4 class="section-label">Description</h4>
                <p class="detail-desc-text">{{ selectedProduct.description }}</p>
              </div>

              <div class="detail-metadata">
                <div class="meta-item">
                  <span class="meta-label">Product ID (UUID)</span>
                  <code class="meta-val">{{ selectedProduct.id }}</code>
                </div>
                <div class="meta-item" v-if="selectedProduct.createdAt">
                  <span class="meta-label">Date Added</span>
                  <span class="meta-val">{{ formatDate(selectedProduct.createdAt) }}</span>
                </div>
              </div>
            </div>

            <footer class="modal-footer detail-footer">
              <button class="btn btn-secondary" @click="closeDetailModal">Close Detail</button>
            </footer>
          </div>
        </Transition>
      </div>
    </Transition>

    <!-- TOAST NOTIFICATIONS -->
    <div class="toasts-wrapper">
      <TransitionGroup name="slide">
        <div 
          v-for="toast in toasts" 
          :key="toast.id" 
          class="toast-alert" 
          :class="toast.type"
        >
          <svg v-if="toast.type === 'success'" xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"></polyline></svg>
          <svg v-else xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"></circle><line x1="12" y1="8" x2="12" y2="12"></line><line x1="12" y1="16" x2="12.01" y2="16"></line></svg>
          <span>{{ toast.message }}</span>
        </div>
      </TransitionGroup>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, watch } from 'vue'

const products = ref([])
const totalProducts = ref(0)
const currentPage = ref(1)
const totalPages = ref(1)
const limit = ref(8)
const searchQuery = ref('')
const isLoading = ref(false)

// Form State
const showAddModal = ref(false)
const newProduct = ref({
  name: '',
  description: '',
  price: ''
})
const isSubmitting = ref(false)
const formErrors = ref({
  name: '',
  description: '',
  price: ''
})

// Detail Modal State
const selectedProduct = ref(null)
const showDetailModal = ref(false)

// Toast State
const toasts = ref([])
const showToast = (message, type = 'success') => {
  const id = Date.now()
  toasts.value.push({ id, message, type })
  setTimeout(() => {
    toasts.value = toasts.value.filter(t => t.id !== id)
  }, 4000)
}

// Fetch Catalog Products
const fetchProducts = async () => {
  isLoading.value = true
  try {
    const url = new URL('http://localhost:3001/api/products')
    url.searchParams.append('page', currentPage.value.toString())
    url.searchParams.append('limit', limit.value.toString())
    if (searchQuery.value.trim()) {
      url.searchParams.append('search', searchQuery.value.trim())
    }

    const res = await $fetch(url.toString())
    products.value = res.data
    totalProducts.value = res.meta.total
    totalPages.value = res.meta.totalPages
  } catch (err) {
    console.error(err)
    showToast('Failed to load products from API server', 'error')
  } finally {
    isLoading.value = false
  }
}

// Search with dynamic input debouncing
let searchTimeout
watch(searchQuery, () => {
  clearTimeout(searchTimeout)
  searchTimeout = setTimeout(() => {
    currentPage.value = 1
    fetchProducts()
  }, 300)
})

watch(currentPage, () => {
  fetchProducts()
})

onMounted(() => {
  fetchProducts()
})

// Helpers & Formatters
const truncateText = (text, maxLength) => {
  if (!text) return ''
  return text.length > maxLength ? text.substring(0, maxLength) + '...' : text
}

const formatPrice = (price) => {
  const parsed = parseFloat(price)
  return isNaN(parsed) ? '0.00' : parsed.toFixed(2)
}

const formatDate = (dateString) => {
  if (!dateString) return ''
  const date = new Date(dateString)
  return date.toLocaleDateString('en-US', {
    year: 'numeric',
    month: 'short',
    day: 'numeric',
    hour: '2-digit',
    minute: '2-digit'
  })
}

// Modal Handlers
const openDetailModal = (product) => {
  selectedProduct.value = product
  showDetailModal.value = true
}

const closeDetailModal = () => {
  showDetailModal.value = false
  selectedProduct.value = null
}

const openAddModal = () => {
  showAddModal.value = true
}

const closeAddModal = () => {
  showAddModal.value = false
  newProduct.value = { name: '', description: '', price: '' }
  formErrors.value = { name: '', description: '', price: '' }
}

const validateForm = () => {
  let isValid = true
  formErrors.value = { name: '', description: '', price: '' }

  if (!newProduct.value.name.trim()) {
    formErrors.value.name = 'Product name is required'
    isValid = false
  }
  
  if (newProduct.value.price === '' || newProduct.value.price === null || newProduct.value.price === undefined) {
    formErrors.value.price = 'Price is required'
    isValid = false
  } else {
    const numericPrice = parseFloat(newProduct.value.price)
    if (isNaN(numericPrice)) {
      formErrors.value.price = 'Price must be a valid number'
      isValid = false
    } else if (numericPrice < 0) {
      formErrors.value.price = 'Price must be 0 or greater'
      isValid = false
    }
  }

  if (!newProduct.value.description.trim()) {
    formErrors.value.description = 'Description is required'
    isValid = false
  }

  return isValid
}

const submitProduct = async () => {
  if (!validateForm()) return
  
  isSubmitting.value = true
  try {
    await $fetch('http://localhost:3001/api/products', {
      method: 'POST',
      body: {
        name: newProduct.value.name.trim(),
        description: newProduct.value.description.trim(),
        price: parseFloat(newProduct.value.price)
      }
    })
    showToast('Product successfully added to catalog!')
    closeAddModal()
    currentPage.value = 1
    fetchProducts()
  } catch (err) {
    console.error(err)
    const errorMsg = err.data?.message || 'Failed to add product to catalog'
    showToast(Array.isArray(errorMsg) ? errorMsg.join(', ') : errorMsg, 'error')
  } finally {
    isSubmitting.value = false
  }
}
</script>

<style>
@import url('https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;500;600;700&display=swap');

/* Dynamic Reset & Design tokens */
:root {
  --font-sans: 'Outfit', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
  
  /* Color Palette (Deep Space Theme) */
  --bg-primary: #080b11;
  --bg-secondary: #111622;
  --accent-cyan: #00f2fe;
  --accent-purple: #9b51e0;
  --text-main: #f3f4f6;
  --text-muted: #9ca3af;
  --border-color: rgba(255, 255, 255, 0.08);
  --border-hover: rgba(0, 242, 254, 0.4);
  
  /* Glassmorphism tokens */
  --glass-bg: rgba(17, 22, 34, 0.65);
  --glass-blur: blur(16px);
  --glass-shadow: 0 8px 32px 0 rgba(0, 0, 0, 0.37);

  /* Utilities */
  --transition-smooth: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  --radius-lg: 16px;
  --radius-md: 10px;
}

* {
  box-sizing: border-box;
  margin: 0;
  padding: 0;
}

body {
  background-color: var(--bg-primary);
  color: var(--text-main);
  font-family: var(--font-sans);
  overflow-x: hidden;
  line-height: 1.5;
  -webkit-font-smoothing: antialiased;
}

/* Ambient glows */
.glow-bg-1, .glow-bg-2 {
  position: fixed;
  width: 50vw;
  height: 50vw;
  border-radius: 50%;
  pointer-events: none;
  filter: blur(150px);
  opacity: 0.15;
  z-index: 0;
}

.glow-bg-1 {
  background: radial-gradient(circle, var(--accent-cyan) 0%, transparent 70%);
  top: -10vw;
  left: -10vw;
}

.glow-bg-2 {
  background: radial-gradient(circle, var(--accent-purple) 0%, transparent 70%);
  bottom: -10vw;
  right: -10vw;
}

/* Main Container Layout */
.app-container {
  position: relative;
  z-index: 1;
  max-width: 1200px;
  margin: 0 auto;
  padding: 40px 20px;
  min-height: 100vh;
  display: flex;
  flex-direction: column;
}

/* Header styling */
.app-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 40px;
  gap: 20px;
}

.brand-title {
  font-size: 2.5rem;
  font-weight: 700;
  letter-spacing: -0.05em;
  background: linear-gradient(135deg, var(--text-main) 30%, var(--accent-cyan) 100%);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  margin-bottom: 4px;
}

.brand-subtitle {
  color: var(--text-muted);
  font-size: 0.95rem;
  font-weight: 400;
}

/* Control bar styling */
.controls-section {
  margin-bottom: 30px;
}

.search-wrapper {
  position: relative;
  width: 100%;
  display: flex;
  align-items: center;
  background: var(--glass-bg);
  backdrop-filter: var(--glass-blur);
  border: 1px solid var(--border-color);
  border-radius: var(--radius-lg);
  padding: 4px 16px;
  box-shadow: var(--glass-shadow);
  transition: var(--transition-smooth);
}

.search-wrapper:focus-within {
  border-color: var(--border-hover);
  box-shadow: 0 0 20px rgba(0, 242, 254, 0.15), var(--glass-shadow);
}

.search-icon {
  color: var(--text-muted);
  margin-right: 12px;
  flex-shrink: 0;
}

.search-input {
  width: 100%;
  background: transparent;
  border: none;
  outline: none;
  color: var(--text-main);
  font-family: var(--font-sans);
  font-size: 1.05rem;
  padding: 12px 0;
}

.search-input::placeholder {
  color: #6b7280;
}

.clear-search-btn {
  background: transparent;
  border: none;
  color: var(--text-muted);
  cursor: pointer;
  padding: 8px;
  display: flex;
  align-items: center;
  justify-content: center;
  border-radius: 50%;
  transition: var(--transition-smooth);
}

.clear-search-btn:hover {
  background: rgba(255, 255, 255, 0.1);
  color: var(--text-main);
}

/* Product Catalog Grid */
.catalog-section {
  flex-grow: 1;
  margin-bottom: 40px;
}

.product-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(260px, 1fr));
  gap: 24px;
}

/* Product Card Glassmorphism Design */
.product-card {
  background: var(--glass-bg);
  backdrop-filter: var(--glass-blur);
  border: 1px solid var(--border-color);
  border-radius: var(--radius-lg);
  padding: 24px;
  display: flex;
  flex-direction: column;
  justify-content: space-between;
  min-height: 230px;
  box-shadow: var(--glass-shadow);
  cursor: pointer;
  transition: var(--transition-smooth);
  position: relative;
  overflow: hidden;
}

.product-card::before {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background: linear-gradient(135deg, rgba(0, 242, 254, 0.05) 0%, rgba(155, 81, 224, 0.05) 100%);
  opacity: 0;
  transition: var(--transition-smooth);
}

.product-card:hover {
  transform: translateY(-6px);
  border-color: var(--border-hover);
  box-shadow: 0 12px 30px rgba(0, 242, 254, 0.08), var(--glass-shadow);
}

.product-card:hover::before {
  opacity: 1;
}

.card-body {
  position: relative;
  z-index: 1;
  margin-bottom: 20px;
}

.product-name {
  font-size: 1.2rem;
  font-weight: 600;
  color: var(--text-main);
  margin-bottom: 10px;
  line-height: 1.3;
}

.product-description {
  color: var(--text-muted);
  font-size: 0.9rem;
  font-weight: 300;
  display: -webkit-box;
  -webkit-line-clamp: 3;
  -webkit-box-orient: vertical;
  overflow: hidden;
  text-overflow: ellipsis;
}

.card-footer {
  position: relative;
  z-index: 1;
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-top: auto;
}

.product-price {
  font-size: 1.3rem;
  font-weight: 700;
  color: var(--accent-cyan);
}

/* Buttons style */
.btn {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
  font-family: var(--font-sans);
  font-weight: 500;
  font-size: 0.95rem;
  padding: 10px 18px;
  border-radius: var(--radius-md);
  border: none;
  cursor: pointer;
  transition: var(--transition-smooth);
}

.btn-primary {
  background: linear-gradient(135deg, var(--accent-cyan) 0%, #00b4d8 100%);
  color: #080b11;
  box-shadow: 0 4px 14px rgba(0, 242, 254, 0.3);
}

.btn-primary:hover:not(:disabled) {
  transform: translateY(-2px);
  box-shadow: 0 6px 20px rgba(0, 242, 254, 0.45);
}

.btn-primary:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

.btn-secondary {
  background: rgba(255, 255, 255, 0.06);
  color: var(--text-main);
  border: 1px solid var(--border-color);
}

.btn-secondary:hover {
  background: rgba(255, 255, 255, 0.12);
  border-color: rgba(255, 255, 255, 0.2);
}

.btn-add {
  padding: 12px 24px;
  font-size: 1rem;
}

.btn-details {
  background: transparent;
  color: var(--text-muted);
  padding: 6px 12px;
  font-size: 0.85rem;
  border: 1px solid transparent;
  border-radius: 6px;
}

.product-card:hover .btn-details {
  color: var(--accent-cyan);
  border-color: rgba(0, 242, 254, 0.2);
  background: rgba(0, 242, 254, 0.05);
}

/* Empty State Card */
.empty-state-card {
  background: var(--glass-bg);
  backdrop-filter: var(--glass-blur);
  border: 1px solid var(--border-color);
  border-radius: var(--radius-lg);
  padding: 60px 20px;
  text-align: center;
  max-width: 500px;
  margin: 60px auto;
  box-shadow: var(--glass-shadow);
}

.empty-icon-wrapper {
  color: var(--text-muted);
  margin-bottom: 20px;
  opacity: 0.7;
}

.empty-state-card h3 {
  font-size: 1.4rem;
  font-weight: 600;
  margin-bottom: 10px;
}

.empty-state-card p {
  color: var(--text-muted);
  font-size: 0.95rem;
  margin-bottom: 24px;
}

/* Skeletons loader */
.skeleton-card {
  pointer-events: none;
}

.skeleton {
  background: linear-gradient(90deg, rgba(255,255,255,0.03) 25%, rgba(255,255,255,0.08) 50%, rgba(255,255,255,0.03) 75%);
  background-size: 200% 100%;
  animation: loading-shimmer 1.5s infinite;
  border-radius: 4px;
}

.skeleton-title {
  height: 22px;
  width: 75%;
  margin-bottom: 15px;
}

.skeleton-text-1 {
  height: 14px;
  width: 100%;
  margin-bottom: 8px;
}

.skeleton-text-2 {
  height: 14px;
  width: 90%;
  margin-bottom: 12px;
}

.skeleton-price {
  height: 24px;
  width: 30%;
}

.skeleton-btn {
  height: 28px;
  width: 40%;
  border-radius: 6px;
}

@keyframes loading-shimmer {
  0% { background-position: 200% 0; }
  100% { background-position: -200% 0; }
}

/* Pagination bar style */
.pagination-section {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-top: auto;
  padding-top: 30px;
  border-top: 1px solid var(--border-color);
  gap: 20px;
  flex-wrap: wrap;
}

.pagination-info {
  font-size: 0.9rem;
  color: var(--text-muted);
}

.highlight {
  color: var(--text-main);
  font-weight: 500;
}

.pagination-controls {
  display: flex;
  align-items: center;
  gap: 12px;
}

.btn-pagination {
  background: var(--glass-bg);
  border: 1px solid var(--border-color);
  color: var(--text-main);
  padding: 8px 14px;
  font-size: 0.85rem;
}

.btn-pagination:hover:not(:disabled) {
  border-color: var(--border-hover);
  color: var(--accent-cyan);
}

.btn-pagination:disabled {
  opacity: 0.4;
  cursor: not-allowed;
}

.page-numbers {
  display: flex;
  gap: 6px;
}

.page-number-btn {
  background: transparent;
  border: 1px solid transparent;
  color: var(--text-muted);
  width: 32px;
  height: 32px;
  border-radius: 8px;
  cursor: pointer;
  font-family: var(--font-sans);
  font-weight: 500;
  font-size: 0.9rem;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: var(--transition-smooth);
}

.page-number-btn:hover {
  background: rgba(255, 255, 255, 0.05);
  color: var(--text-main);
}

.page-number-btn.active {
  background: var(--accent-cyan);
  color: #080b11;
  border-color: var(--accent-cyan);
}

/* Modals structures */
.modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  width: 100vw;
  height: 100vh;
  background: rgba(4, 6, 10, 0.8);
  backdrop-filter: blur(8px);
  z-index: 100;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 20px;
}

.modal-content {
  width: 100%;
  max-width: 540px;
  border-radius: var(--radius-lg);
  border: 1px solid var(--border-color);
  overflow: hidden;
  box-shadow: 0 20px 50px rgba(0,0,0,0.5);
  background: var(--bg-secondary);
  display: flex;
  flex-direction: column;
}

.glass-panel {
  background: rgba(13, 18, 30, 0.9);
  backdrop-filter: var(--glass-blur);
}

.modal-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 24px;
  border-bottom: 1px solid var(--border-color);
}

.modal-header h3 {
  font-size: 1.3rem;
  font-weight: 600;
}

.close-modal-btn {
  background: transparent;
  border: none;
  color: var(--text-muted);
  cursor: pointer;
  padding: 4px;
  display: flex;
  align-items: center;
  justify-content: center;
  border-radius: 6px;
  transition: var(--transition-smooth);
}

.close-modal-btn:hover {
  background: rgba(255, 255, 255, 0.05);
  color: var(--text-main);
}

/* Forms layout */
.modal-form {
  padding: 24px;
}

.form-group {
  margin-bottom: 20px;
}

.form-group label {
  display: block;
  font-size: 0.88rem;
  font-weight: 500;
  color: var(--text-muted);
  margin-bottom: 8px;
}

.form-control {
  width: 100%;
  background: rgba(255, 255, 255, 0.03);
  border: 1px solid var(--border-color);
  border-radius: var(--radius-md);
  color: var(--text-main);
  font-family: var(--font-sans);
  font-size: 0.95rem;
  padding: 12px 16px;
  outline: none;
  transition: var(--transition-smooth);
}

.form-control::placeholder {
  color: #4b5563;
}

.form-control:focus {
  border-color: var(--border-hover);
  background: rgba(255, 255, 255, 0.05);
  box-shadow: 0 0 10px rgba(0, 242, 254, 0.05);
}

.form-control.is-invalid {
  border-color: #ef4444;
  box-shadow: 0 0 10px rgba(239, 68, 68, 0.1);
}

.text-area {
  resize: none;
}

.error-msg {
  display: block;
  font-size: 0.8rem;
  color: #ef4444;
  margin-top: 6px;
}

.modal-actions {
  display: flex;
  justify-content: flex-end;
  gap: 12px;
  margin-top: 30px;
}

/* Spinner loader inside button */
.spinner {
  width: 16px;
  height: 16px;
  border: 2px solid rgba(0, 0, 0, 0.1);
  border-top-color: currentColor;
  border-radius: 50%;
  animation: spin 0.8s linear infinite;
}

@keyframes spin {
  to { transform: rotate(360deg); }
}

/* Detail modal styles */
.detail-modal {
  max-width: 600px;
}

.detail-body {
  padding: 30px 24px;
}

.detail-name {
  font-size: 1.8rem;
  font-weight: 700;
  margin-bottom: 12px;
  line-height: 1.2;
}

.detail-price-badge {
  display: inline-block;
  background: rgba(0, 242, 254, 0.1);
  border: 1px solid rgba(0, 242, 254, 0.2);
  color: var(--accent-cyan);
  font-size: 1.3rem;
  font-weight: 700;
  padding: 4px 14px;
  border-radius: 20px;
  margin-bottom: 30px;
}

.detail-section {
  margin-bottom: 30px;
}

.section-label {
  font-size: 0.8rem;
  text-transform: uppercase;
  letter-spacing: 0.05em;
  color: var(--text-muted);
  margin-bottom: 10px;
  font-weight: 600;
}

.detail-desc-text {
  font-size: 1rem;
  font-weight: 300;
  line-height: 1.6;
  white-space: pre-wrap;
  color: rgba(243, 244, 246, 0.9);
}

.detail-metadata {
  display: grid;
  grid-template-columns: 1fr;
  gap: 16px;
  background: rgba(255, 255, 255, 0.02);
  border: 1px solid var(--border-color);
  border-radius: var(--radius-md);
  padding: 16px;
}

.meta-item {
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.meta-label {
  font-size: 0.75rem;
  color: var(--text-muted);
  font-weight: 500;
}

.meta-val {
  font-size: 0.9rem;
  color: var(--text-main);
}

code.meta-val {
  font-family: monospace;
  word-break: break-all;
  background: rgba(0,0,0,0.2);
  padding: 4px 8px;
  border-radius: 4px;
  font-size: 0.85rem;
}

.detail-footer {
  padding: 20px 24px;
  border-top: 1px solid var(--border-color);
  display: flex;
  justify-content: flex-end;
}

/* Toast alert elements */
.toasts-wrapper {
  position: fixed;
  bottom: 24px;
  right: 24px;
  z-index: 200;
  display: flex;
  flex-direction: column;
  gap: 12px;
  pointer-events: none;
}

.toast-alert {
  pointer-events: auto;
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 16px 20px;
  border-radius: var(--radius-md);
  font-size: 0.92rem;
  font-weight: 500;
  min-width: 280px;
  box-shadow: 0 10px 25px rgba(0, 0, 0, 0.4);
  backdrop-filter: var(--glass-blur);
}

.toast-alert.success {
  background: rgba(16, 185, 129, 0.15);
  border: 1px solid rgba(16, 185, 129, 0.3);
  color: #10b981;
}

.toast-alert.error {
  background: rgba(239, 68, 68, 0.15);
  border: 1px solid rgba(239, 68, 68, 0.3);
  color: #ef4444;
}

/* Vue Transitions */
.fade-enter-active, .fade-leave-active {
  transition: opacity 0.25s ease;
}
.fade-enter-from, .fade-leave-to {
  opacity: 0;
}

.zoom-enter-active, .zoom-leave-active {
  transition: transform 0.3s cubic-bezier(0.34, 1.56, 0.64, 1), opacity 0.25s ease;
}
.zoom-enter-from, .zoom-leave-to {
  transform: scale(0.95);
  opacity: 0;
}

.slide-enter-active, .slide-leave-active {
  transition: transform 0.3s cubic-bezier(0.16, 1, 0.3, 1), opacity 0.25s ease;
}
.slide-enter-from {
  transform: translateY(20px);
  opacity: 0;
}
.slide-leave-to {
  transform: translateX(100px);
  opacity: 0;
}

/* Mobile Responsive */
@media (max-width: 640px) {
  .app-header {
    flex-direction: column;
    align-items: flex-start;
  }
  .btn-add {
    width: 100%;
  }
  .pagination-section {
    flex-direction: column;
    align-items: center;
    text-align: center;
  }
}
</style>
