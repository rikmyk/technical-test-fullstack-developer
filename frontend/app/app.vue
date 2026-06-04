<template>
  <div class="app-container">
    <!-- Global Header -->
    <header class="app-header">
      <div class="header-main">
        <div class="brand-group">
          <span class="brand-logo"></span>
          <h1 class="brand-title">VapeCloud Indo.</h1>
        </div>
        <p class="brand-subtitle">Designed for the finest vapor experience.</p>
      </div>
      <button class="btn btn-primary btn-add" @click="openAddModal">
        <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><line x1="12" y1="5" x2="12" y2="19"></line><line x1="5" y1="12" x2="19" y2="12"></line></svg>
        <span>Add Product</span>
      </button>
    </header>

    <!-- Hero Section / Promo Banner -->
    <section class="hero-banner">
      <div class="hero-content">
        <span class="badge-promo">New Collection</span>
        <h2 class="hero-headline">The Liquid & Mod Catalog.</h2>
        <p class="hero-subheadline">Browse and manage premium local and imported collections with enterprise-level simplicity.</p>
      </div>
    </section>

    <!-- Controls & Search -->
    <section class="controls-section">
      <div class="search-wrapper">
        <svg class="search-icon" xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="11" cy="11" r="8"></circle><line x1="21" y1="21" x2="16.65" y2="16.65"></line></svg>
        <input 
          id="search-input"
          type="text" 
          v-model="searchQuery" 
          placeholder="Search collections (e.g. Liquid, Mod, RDA)..." 
          class="search-input"
          autocomplete="off"
        />
        <button v-if="searchQuery" class="clear-search-btn" @click="searchQuery = ''">
          <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><line x1="18" y1="6" x2="6" y2="18"></line><line x1="6" y1="6" x2="18" y2="18"></line></svg>
        </button>
      </div>
    </section>

    <!-- Catalog Section -->
    <main class="catalog-section">
      <!-- Loading skeleton grid -->
      <div v-if="isLoading" class="product-grid">
        <div v-for="n in 8" :key="'skeleton-' + n" class="product-card skeleton-card">
          <div class="skeleton skeleton-image"></div>
          <div class="card-info">
            <div class="skeleton skeleton-title"></div>
            <div class="skeleton skeleton-text"></div>
            <div class="skeleton skeleton-price"></div>
          </div>
        </div>
      </div>

      <!-- Empty State -->
      <div v-else-if="products.length === 0" class="empty-state-card">
        <div class="empty-icon"></div>
        <h3>No Products Found</h3>
        <p>No collections match your criteria. Try adjusting your query or insert a new product entry.</p>
        <div class="empty-actions">
          <button v-if="searchQuery" class="btn btn-secondary" @click="searchQuery = ''">Clear Search</button>
          <button class="btn btn-primary" @click="openAddModal">Add Product</button>
        </div>
      </div>

      <!-- Active Bento-style Catalog Grid -->
      <div v-else class="product-grid">
        <div 
          v-for="(product, idx) in products" 
          :key="product.id" 
          class="product-card"
          :class="{ 'card-highlight': idx % 5 === 0 }"
          @click="openDetailModal(product)"
        >
          <!-- Beautiful abstract line-art visual placeholder -->
          <div class="product-image-container">
            <svg viewBox="0 0 100 100" fill="none" xmlns="http://www.w3.org/2000/svg" class="geometric-pattern">
              <defs>
                <linearGradient :id="'gradient-' + product.id" x1="0%" y1="0%" x2="100%" y2="100%">
                  <stop offset="0%" :stop-color="getPatternColors(idx).start" />
                  <stop offset="100%" :stop-color="getPatternColors(idx).end" />
                </linearGradient>
              </defs>
              <rect width="100" height="100" :fill="'url(#gradient-' + product.id + ')'" />
              <!-- Abstract circular layouts -->
              <circle cx="50" cy="50" :r="20 + (idx % 3) * 6" stroke="rgba(255,255,255,0.15)" stroke-width="1.5" />
              <circle cx="50" cy="50" :r="10 + (idx % 3) * 4" stroke="rgba(255,255,255,0.25)" stroke-width="1" stroke-dasharray="3 3" />
              <path d="M50 30L55 45H70L58 53L62 68L50 58L38 68L42 53L30 45H45L50 30Z" fill="rgba(255,255,255,0.06)" />
            </svg>
            <span class="category-tag">Premium</span>
          </div>

          <div class="card-info">
            <h3 class="product-name">{{ product.name }}</h3>
            <p class="product-description">{{ truncateText(product.description, 85) }}</p>
            
            <div class="card-footer">
              <span class="product-price">Rp {{ formatPrice(product.price) }}</span>
              <button class="btn btn-link" @click.stop="openDetailModal(product)">
                <span>Learn more</span>
                <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><polyline points="9 18 15 12 9 6"></polyline></svg>
              </button>
            </div>
          </div>
        </div>
      </div>
    </main>

    <!-- Pagination -->
    <footer v-if="!isLoading && products.length > 0" class="pagination-section">
      <span class="pagination-summary">
        Showing page <strong>{{ currentPage }}</strong> of {{ totalPages }} ({{ totalProducts }} total items)
      </span>
      <div class="pagination-actions">
        <button 
          id="prev-page-btn"
          class="btn btn-secondary btn-pagination" 
          :disabled="currentPage === 1" 
          @click="currentPage--"
        >
          <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><polyline points="15 18 9 12 15 6"></polyline></svg>
          <span>Back</span>
        </button>

        <div class="page-indices">
          <button 
            v-for="page in totalPages" 
            :key="page" 
            class="page-index-btn"
            :class="{ active: page === currentPage }"
            @click="currentPage = page"
          >
            {{ page }}
          </button>
        </div>

        <button 
          id="next-page-btn"
          class="btn btn-secondary btn-pagination" 
          :disabled="currentPage === totalPages" 
          @click="currentPage++"
        >
          <span>Next</span>
          <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><polyline points="9 18 15 12 9 6"></polyline></svg>
        </button>
      </div>
    </footer>

    <!-- ADD PRODUCT MODAL -->
    <Transition name="fade">
      <div v-if="showAddModal" class="modal-overlay" @click.self="closeAddModal">
        <Transition name="slide-up">
          <div class="modal-card" role="dialog" aria-modal="true">
            <header class="modal-header">
              <h3 class="modal-title">New Product Spec</h3>
              <button class="btn-close" @click="closeAddModal">
                <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="18" y1="6" x2="6" y2="18"></line><line x1="6" y1="6" x2="18" y2="18"></line></svg>
              </button>
            </header>

            <form class="modal-body form-layout" @submit.prevent="submitProduct">
              <div class="form-group">
                <label for="product-name">Product Name</label>
                <input 
                  id="product-name"
                  type="text" 
                  v-model="newProduct.name" 
                  placeholder="e.g. Liquid Oat Drip V1 60ml" 
                  class="form-control"
                  :class="{ 'is-invalid': formErrors.name }"
                />
                <span v-if="formErrors.name" class="error-text">{{ formErrors.name }}</span>
              </div>

              <div class="form-group">
                <label for="product-price">Price (Rupiah Rp)</label>
                <div class="price-input-wrapper">
                  <span class="currency-prefix">Rp</span>
                  <input 
                    id="product-price"
                    type="number" 
                    v-model.number="newProduct.price" 
                    placeholder="150000" 
                    class="form-control input-price"
                    :class="{ 'is-invalid': formErrors.price }"
                  />
                </div>
                <span v-if="formErrors.price" class="error-text">{{ formErrors.price }}</span>
              </div>

              <div class="form-group">
                <label for="product-desc">Description</label>
                <textarea 
                  id="product-desc"
                  rows="4" 
                  v-model="newProduct.description" 
                  placeholder="Describe taste profile, PG/VG ratio, nicotine strength, or mod specifications..." 
                  class="form-control text-area"
                  :class="{ 'is-invalid': formErrors.description }"
                ></textarea>
                <span v-if="formErrors.description" class="error-text">{{ formErrors.description }}</span>
              </div>

              <div class="form-actions">
                <button type="button" class="btn btn-secondary" @click="closeAddModal">Cancel</button>
                <button type="submit" class="btn btn-primary" :disabled="isSubmitting">
                  <span v-if="isSubmitting" class="spinner"></span>
                  <span>{{ isSubmitting ? 'Adding...' : 'Add to Catalog' }}</span>
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
        <Transition name="slide-up">
          <div class="modal-card detail-card" role="dialog" aria-modal="true">
            <header class="modal-header">
              <span class="modal-subtitle-tag">Specifications</span>
              <button class="btn-close" @click="closeDetailModal">
                <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="18" y1="6" x2="6" y2="18"></line><line x1="6" y1="6" x2="18" y2="18"></line></svg>
              </button>
            </header>

            <div class="modal-body detail-grid">
              <!-- Left Column: Premium Preview Pattern -->
              <div class="detail-preview-panel">
                <svg viewBox="0 0 100 100" fill="none" xmlns="http://www.w3.org/2000/svg" class="geometric-pattern">
                  <defs>
                    <linearGradient id="detail-gradient" x1="0%" y1="0%" x2="100%" y2="100%">
                      <stop offset="0%" stop-color="#0F172A" />
                      <stop offset="100%" stop-color="#334155" />
                    </linearGradient>
                  </defs>
                  <rect width="100" height="100" fill="url(#detail-gradient)" />
                  <circle cx="50" cy="50" r="32" stroke="rgba(255,255,255,0.08)" stroke-width="2" />
                  <circle cx="50" cy="50" r="22" stroke="rgba(255,255,255,0.12)" stroke-width="1" stroke-dasharray="4 4" />
                  <circle cx="50" cy="50" r="12" stroke="rgba(255,255,255,0.2)" stroke-width="1.5" />
                </svg>
                <div class="detail-preview-badge">VapeCloud Premium</div>
              </div>

              <!-- Right Column: Product Info -->
              <div class="detail-info-panel">
                <h2 class="detail-title">{{ selectedProduct.name }}</h2>
                <div class="detail-price-section">
                  <span class="detail-price-label">Price</span>
                  <span class="detail-price-value">Rp {{ formatPrice(selectedProduct.price) }}</span>
                </div>

                <div class="detail-description-section">
                  <h4>Description</h4>
                  <p>{{ selectedProduct.description }}</p>
                </div>

                <div class="detail-meta-table">
                  <div class="meta-row">
                    <span class="meta-col-label">Product ID</span>
                    <span class="meta-col-value font-mono">{{ selectedProduct.id }}</span>
                  </div>
                  <div class="meta-row" v-if="selectedProduct.createdAt">
                    <span class="meta-col-label">Date Added</span>
                    <span class="meta-col-value">{{ formatDate(selectedProduct.createdAt) }}</span>
                  </div>
                  <div class="meta-row">
                    <span class="meta-col-label">Status</span>
                    <span class="meta-col-value text-success">Active / Available</span>
                  </div>
                </div>
              </div>
            </div>

            <footer class="modal-footer">
              <button class="btn btn-secondary btn-full" @click="closeDetailModal">Close Specifications</button>
            </footer>
          </div>
        </Transition>
      </div>
    </Transition>

    <!-- TOASTS -->
    <div class="toast-container">
      <TransitionGroup name="toast-slide">
        <div 
          v-for="toast in toasts" 
          :key="toast.id" 
          class="toast-alert" 
          :class="toast.type"
        >
          <span class="toast-dot"></span>
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

// Toast notifications
const toasts = ref([])
const showToast = (message, type = 'success') => {
  const id = Date.now()
  toasts.value.push({ id, message, type })
  setTimeout(() => {
    toasts.value = toasts.value.filter(t => t.id !== id)
  }, 3500)
}

// Color patterns for premium cards
const getPatternColors = (idx) => {
  const gradients = [
    { start: '#3B82F6', end: '#1D4ED8' }, // Blue
    { start: '#10B981', end: '#047857' }, // Emerald
    { start: '#8B5CF6', end: '#6D28D9' }, // Violet
    { start: '#EF4444', end: '#B91C1C' }, // Rose
    { start: '#F59E0B', end: '#B45309' }  // Amber
  ]
  return gradients[idx % gradients.length]
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
    showToast('Failed to connect to backend product service', 'error')
  } finally {
    isLoading.value = false
  }
}

// Debounced input search
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

// Helpers
const truncateText = (text, maxLength) => {
  if (!text) return ''
  return text.length > maxLength ? text.substring(0, maxLength) + '...' : text
}

const formatPrice = (price) => {
  const parsed = parseFloat(price)
  if (isNaN(parsed)) return '0'
  return new Intl.NumberFormat('id-ID', {
    minimumFractionDigits: 0,
    maximumFractionDigits: 0
  }).format(parsed)
}

const formatDate = (dateString) => {
  if (!dateString) return ''
  const date = new Date(dateString)
  return date.toLocaleDateString('en-US', {
    year: 'numeric',
    month: 'long',
    day: 'numeric'
  })
}

// Modal actions
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
    showToast('Product added to catalog successfully')
    closeAddModal()
    currentPage.value = 1
    fetchProducts()
  } catch (err) {
    console.error(err)
    const errorMsg = err.data?.message || 'Failed to insert product record'
    showToast(Array.isArray(errorMsg) ? errorMsg.join(', ') : errorMsg, 'error')
  } finally {
    isSubmitting.value = false
  }
}
</script>

<style>
@import url('https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap');

/* Color tokens: Apple / Stripe / Vercel style */
:root {
  --font-sans: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
  
  --bg-color: #FAFAFA;
  --surface-color: #FFFFFF;
  --primary-color: #2563EB;
  --primary-hover: #1D4ED8;
  --text-primary: #0F172A;
  --text-secondary: #64748B;
  --border-color: #E2E8F0;
  
  --shadow-sm: 0 1px 2px 0 rgba(0, 0, 0, 0.05);
  --shadow-md: 0 4px 6px -1px rgba(0, 0, 0, 0.05), 0 2px 4px -1px rgba(0, 0, 0, 0.03);
  --shadow-lg: 0 10px 15px -3px rgba(0, 0, 0, 0.04), 0 4px 6px -2px rgba(0, 0, 0, 0.02);
  --shadow-card: 0 20px 25px -5px rgba(0, 0, 0, 0.05), 0 10px 10px -5px rgba(0, 0, 0, 0.02);
  
  --transition-smooth: all 0.25s cubic-bezier(0.16, 1, 0.3, 1);
  --radius-lg: 16px;
  --radius-md: 10px;
}

/* Global Reset */
* {
  box-sizing: border-box;
  margin: 0;
  padding: 0;
}

body {
  background-color: var(--bg-color);
  color: var(--text-primary);
  font-family: var(--font-sans);
  line-height: 1.5;
  -webkit-font-smoothing: antialiased;
  overflow-x: hidden;
}

/* Container */
.app-container {
  max-width: 1280px;
  margin: 0 auto;
  padding: 40px 24px;
  min-height: 100vh;
  display: flex;
  flex-direction: column;
}

/* Apple-style Header */
.app-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding-bottom: 24px;
  border-bottom: 1px solid var(--border-color);
  margin-bottom: 40px;
  gap: 20px;
}

.brand-group {
  display: flex;
  align-items: center;
  gap: 8px;
}

.brand-logo {
  font-size: 1.8rem;
  color: var(--text-primary);
  user-select: none;
}

.brand-title {
  font-size: 1.6rem;
  font-weight: 700;
  letter-spacing: -0.03em;
  color: var(--text-primary);
}

.brand-subtitle {
  color: var(--text-secondary);
  font-size: 0.9rem;
  font-weight: 400;
  margin-top: 2px;
}

/* Apple Store Inspired Hero banner */
.hero-banner {
  background-color: var(--surface-color);
  border: 1px solid var(--border-color);
  border-radius: var(--radius-lg);
  padding: 48px;
  margin-bottom: 40px;
  box-shadow: var(--shadow-sm);
  position: relative;
  overflow: hidden;
}

.hero-banner::after {
  content: '';
  position: absolute;
  top: 0;
  right: 0;
  width: 40%;
  height: 100%;
  background: radial-gradient(circle, rgba(37,99,235,0.03) 0%, transparent 70%);
  pointer-events: none;
}

.badge-promo {
  display: inline-block;
  font-size: 0.75rem;
  font-weight: 600;
  text-transform: uppercase;
  letter-spacing: 0.05em;
  color: var(--primary-color);
  margin-bottom: 12px;
}

.hero-headline {
  font-size: 2.2rem;
  font-weight: 700;
  letter-spacing: -0.04em;
  color: var(--text-primary);
  margin-bottom: 12px;
}

.hero-subheadline {
  font-size: 1.1rem;
  font-weight: 400;
  color: var(--text-secondary);
  max-width: 600px;
  line-height: 1.6;
}

/* Controls (Search Bar) */
.controls-section {
  margin-bottom: 32px;
}

.search-wrapper {
  position: relative;
  width: 100%;
  display: flex;
  align-items: center;
  background: var(--surface-color);
  border: 1px solid var(--border-color);
  border-radius: var(--radius-md);
  padding: 4px 16px;
  box-shadow: var(--shadow-sm);
  transition: var(--transition-smooth);
}

.search-wrapper:focus-within {
  border-color: var(--primary-color);
  box-shadow: 0 0 0 3px rgba(37, 99, 235, 0.1);
}

.search-icon {
  color: var(--text-secondary);
  margin-right: 12px;
  flex-shrink: 0;
}

.search-input {
  width: 100%;
  background: transparent;
  border: none;
  outline: none;
  color: var(--text-primary);
  font-family: var(--font-sans);
  font-size: 1rem;
  padding: 14px 0;
}

.search-input::placeholder {
  color: var(--text-secondary);
}

.clear-search-btn {
  background: transparent;
  border: none;
  color: var(--text-secondary);
  cursor: pointer;
  padding: 6px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: var(--transition-smooth);
}

.clear-search-btn:hover {
  background: #F1F5F9;
  color: var(--text-primary);
}

/* Catalog Section */
.catalog-section {
  flex-grow: 1;
  margin-bottom: 48px;
}

/* Grid Layout: Premium Bento inspired grid */
.product-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
  gap: 32px;
}

/* Product Card */
.product-card {
  background: var(--surface-color);
  border: 1px solid var(--border-color);
  border-radius: var(--radius-lg);
  overflow: hidden;
  box-shadow: var(--shadow-sm);
  display: flex;
  flex-direction: column;
  cursor: pointer;
  transition: var(--transition-smooth);
}

.product-card:hover {
  transform: translateY(-4px);
  box-shadow: var(--shadow-lg);
  border-color: #CBD5E1;
}

/* Bento highlight rules */
.product-grid .card-highlight {
  grid-column: span 1;
}

@media (min-width: 1024px) {
  .product-grid .card-highlight {
    grid-column: span 2;
    flex-direction: row;
  }
  .product-grid .card-highlight .product-image-container {
    width: 45%;
    height: 100%;
    min-height: 280px;
  }
  .product-grid .card-highlight .card-info {
    width: 55%;
    display: flex;
    flex-direction: column;
    justify-content: center;
    padding: 32px;
  }
}

.product-image-container {
  height: 180px;
  width: 100%;
  position: relative;
  overflow: hidden;
  background-color: #F1F5F9;
}

.geometric-pattern {
  width: 100%;
  height: 100%;
  object-fit: cover;
  transition: var(--transition-smooth);
}

.product-card:hover .geometric-pattern {
  transform: scale(1.05);
}

.category-tag {
  position: absolute;
  top: 12px;
  left: 12px;
  background: rgba(255, 255, 255, 0.9);
  backdrop-filter: blur(4px);
  color: var(--text-primary);
  font-size: 0.7rem;
  font-weight: 600;
  padding: 4px 8px;
  border-radius: 20px;
  letter-spacing: 0.02em;
  box-shadow: var(--shadow-sm);
}

.card-info {
  padding: 24px;
  display: flex;
  flex-direction: column;
  flex-grow: 1;
}

.product-name {
  font-size: 1.15rem;
  font-weight: 600;
  color: var(--text-primary);
  margin-bottom: 8px;
  letter-spacing: -0.02em;
}

.product-description {
  font-size: 0.88rem;
  color: var(--text-secondary);
  margin-bottom: 20px;
  line-height: 1.5;
  font-weight: 400;
}

.card-footer {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-top: auto;
  padding-top: 16px;
  border-top: 1px solid #F1F5F9;
}

.product-price {
  font-size: 1.2rem;
  font-weight: 700;
  color: var(--text-primary);
  letter-spacing: -0.03em;
}

/* Buttons styling */
.btn {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  gap: 6px;
  font-family: var(--font-sans);
  font-size: 0.9rem;
  font-weight: 500;
  padding: 10px 18px;
  border-radius: var(--radius-md);
  border: none;
  cursor: pointer;
  transition: var(--transition-smooth);
}

.btn-primary {
  background-color: var(--primary-color);
  color: #FFFFFF;
  box-shadow: 0 2px 4px rgba(37, 99, 235, 0.15);
}

.btn-primary:hover:not(:disabled) {
  background-color: var(--primary-hover);
}

.btn-primary:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

.btn-secondary {
  background-color: var(--surface-color);
  color: var(--text-primary);
  border: 1px solid var(--border-color);
}

.btn-secondary:hover {
  background-color: #F8FAFC;
  border-color: #CBD5E1;
}

.btn-add {
  font-weight: 600;
  padding: 12px 20px;
  border-radius: 24px;
  box-shadow: 0 4px 6px rgba(37, 99, 235, 0.1);
}

.btn-link {
  background: transparent;
  color: var(--primary-color);
  padding: 6px 12px;
  font-weight: 600;
  border-radius: 20px;
}

.btn-link:hover {
  background-color: rgba(37, 99, 235, 0.05);
  transform: translateX(2px);
}

.btn-full {
  width: 100%;
}

/* Empty State */
.empty-state-card {
  background: var(--surface-color);
  border: 1px solid var(--border-color);
  border-radius: var(--radius-lg);
  padding: 64px 32px;
  text-align: center;
  max-width: 480px;
  margin: 48px auto;
  box-shadow: var(--shadow-sm);
}

.empty-icon {
  font-size: 3rem;
  color: var(--text-secondary);
  margin-bottom: 16px;
  user-select: none;
}

.empty-state-card h3 {
  font-size: 1.25rem;
  font-weight: 600;
  margin-bottom: 8px;
}

.empty-state-card p {
  color: var(--text-secondary);
  font-size: 0.92rem;
  margin-bottom: 24px;
}

.empty-actions {
  display: flex;
  justify-content: center;
  gap: 12px;
}

/* Skeleton Loading cards */
.skeleton-card {
  pointer-events: none;
}

.skeleton {
  background: linear-gradient(90deg, #F1F5F9 25%, #E2E8F0 50%, #F1F5F9 75%);
  background-size: 200% 100%;
  animation: shimmer 1.5s infinite;
}

.skeleton-image {
  height: 180px;
  width: 100%;
}

.skeleton-title {
  height: 20px;
  width: 60%;
  margin-bottom: 12px;
  border-radius: 4px;
}

.skeleton-text {
  height: 14px;
  width: 90%;
  margin-bottom: 8px;
  border-radius: 4px;
}

.skeleton-price {
  height: 24px;
  width: 30%;
  margin-top: 12px;
  border-radius: 4px;
}

@keyframes shimmer {
  0% { background-position: 200% 0; }
  100% { background-position: -200% 0; }
}

/* Pagination Section */
.pagination-section {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding-top: 24px;
  border-top: 1px solid var(--border-color);
  gap: 20px;
  flex-wrap: wrap;
}

.pagination-summary {
  font-size: 0.88rem;
  color: var(--text-secondary);
}

.pagination-actions {
  display: flex;
  align-items: center;
  gap: 16px;
}

.btn-pagination {
  padding: 8px 16px;
  font-size: 0.85rem;
}

.btn-pagination:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.page-indices {
  display: flex;
  gap: 6px;
}

.page-index-btn {
  background: transparent;
  border: none;
  color: var(--text-secondary);
  width: 34px;
  height: 34px;
  border-radius: 50%;
  cursor: pointer;
  font-family: var(--font-sans);
  font-weight: 500;
  font-size: 0.88rem;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: var(--transition-smooth);
}

.page-index-btn:hover {
  background-color: #F1F5F9;
  color: var(--text-primary);
}

.page-index-btn.active {
  background-color: var(--text-primary);
  color: #FFFFFF;
}

/* Modals overlays & Cards */
.modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  width: 100vw;
  height: 100vh;
  background: rgba(15, 23, 42, 0.4);
  backdrop-filter: blur(4px);
  z-index: 100;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 24px;
}

.modal-card {
  background: var(--surface-color);
  border: 1px solid var(--border-color);
  border-radius: var(--radius-lg);
  box-shadow: var(--shadow-card);
  width: 100%;
  max-width: 500px;
  overflow: hidden;
  display: flex;
  flex-direction: column;
}

.modal-header {
  padding: 24px;
  border-bottom: 1px solid #F1F5F9;
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.modal-title {
  font-size: 1.25rem;
  font-weight: 700;
  letter-spacing: -0.02em;
}

.btn-close {
  background: transparent;
  border: none;
  color: var(--text-secondary);
  cursor: pointer;
  padding: 4px;
  border-radius: 6px;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: var(--transition-smooth);
}

.btn-close:hover {
  background: #F1F5F9;
  color: var(--text-primary);
}

.form-layout {
  padding: 24px;
}

.form-group {
  margin-bottom: 20px;
}

.form-group label {
  display: block;
  font-size: 0.85rem;
  font-weight: 600;
  color: var(--text-primary);
  margin-bottom: 6px;
}

.form-control {
  width: 100%;
  background-color: #FAFAFA;
  border: 1px solid var(--border-color);
  border-radius: var(--radius-md);
  color: var(--text-primary);
  font-family: var(--font-sans);
  font-size: 0.92rem;
  padding: 12px 14px;
  outline: none;
  transition: var(--transition-smooth);
}

.form-control:focus {
  background-color: var(--surface-color);
  border-color: var(--primary-color);
  box-shadow: 0 0 0 3px rgba(37, 99, 235, 0.08);
}

.form-control.is-invalid {
  border-color: #EF4444;
  background-color: #FEF2F2;
}

.price-input-wrapper {
  position: relative;
  display: flex;
  align-items: center;
}

.currency-prefix {
  position: absolute;
  left: 14px;
  color: var(--text-secondary);
  font-weight: 500;
  font-size: 0.92rem;
  pointer-events: none;
}

.input-price {
  padding-left: 36px;
}

.text-area {
  resize: none;
}

.error-text {
  font-size: 0.8rem;
  color: #EF4444;
  margin-top: 6px;
  display: block;
}

.form-actions {
  display: flex;
  justify-content: flex-end;
  gap: 12px;
  margin-top: 28px;
}

.spinner {
  width: 16px;
  height: 16px;
  border: 2px solid rgba(255,255,255,0.2);
  border-top-color: currentColor;
  border-radius: 50%;
  animation: spin 0.8s linear infinite;
}

@keyframes spin {
  to { transform: rotate(360deg); }
}

/* Detail Card custom grid layout */
.detail-card {
  max-width: 680px;
}

.modal-subtitle-tag {
  font-size: 0.75rem;
  font-weight: 700;
  text-transform: uppercase;
  letter-spacing: 0.05em;
  color: var(--text-secondary);
}

.detail-grid {
  display: grid;
  grid-template-columns: 1fr;
  padding: 0;
}

@media (min-width: 640px) {
  .detail-grid {
    grid-template-columns: 2fr 3fr;
  }
}

.detail-preview-panel {
  position: relative;
  background-color: #0F172A;
  display: flex;
  flex-direction: column;
  justify-content: center;
  align-items: center;
  min-height: 240px;
  overflow: hidden;
}

.detail-preview-panel .geometric-pattern {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
}

.detail-preview-badge {
  position: relative;
  z-index: 1;
  background: rgba(255, 255, 255, 0.1);
  border: 1px solid rgba(255, 255, 255, 0.15);
  color: #FFFFFF;
  font-size: 0.75rem;
  padding: 6px 12px;
  border-radius: 20px;
  backdrop-filter: blur(8px);
}

.detail-info-panel {
  padding: 32px;
  display: flex;
  flex-direction: column;
}

.detail-title {
  font-size: 1.5rem;
  font-weight: 700;
  letter-spacing: -0.03em;
  margin-bottom: 12px;
}

.detail-price-section {
  display: flex;
  flex-direction: column;
  margin-bottom: 24px;
}

.detail-price-label {
  font-size: 0.75rem;
  font-weight: 600;
  text-transform: uppercase;
  color: var(--text-secondary);
  letter-spacing: 0.05em;
  margin-bottom: 4px;
}

.detail-price-value {
  font-size: 1.8rem;
  font-weight: 800;
  color: var(--text-primary);
  letter-spacing: -0.03em;
}

.detail-description-section {
  margin-bottom: 24px;
}

.detail-description-section h4 {
  font-size: 0.85rem;
  font-weight: 600;
  text-transform: uppercase;
  color: var(--text-secondary);
  margin-bottom: 8px;
}

.detail-description-section p {
  font-size: 0.95rem;
  color: var(--text-primary);
  line-height: 1.6;
}

.detail-meta-table {
  border-top: 1px solid #F1F5F9;
  padding-top: 16px;
}

.meta-row {
  display: flex;
  justify-content: space-between;
  font-size: 0.82rem;
  padding: 6px 0;
}

.meta-col-label {
  color: var(--text-secondary);
  font-weight: 500;
}

.meta-col-value {
  color: var(--text-primary);
  font-weight: 600;
}

.font-mono {
  font-family: monospace;
}

.text-success {
  color: #10B981;
}

.modal-footer {
  padding: 16px 24px;
  background-color: #FAFAFA;
  border-top: 1px solid #F1F5F9;
}

/* Toast Container (Apple-style sleek alert) */
.toast-container {
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
  background: var(--surface-color);
  border: 1px solid var(--border-color);
  border-radius: var(--radius-md);
  padding: 14px 20px;
  font-size: 0.88rem;
  font-weight: 500;
  color: var(--text-primary);
  box-shadow: var(--shadow-lg);
  display: flex;
  align-items: center;
  gap: 10px;
  min-width: 260px;
}

.toast-dot {
  width: 8px;
  height: 8px;
  border-radius: 50%;
  flex-shrink: 0;
}

.toast-alert.success .toast-dot {
  background-color: #10B981;
}

.toast-alert.error .toast-dot {
  background-color: #EF4444;
}

/* Vue Animations */
.fade-enter-active, .fade-leave-active {
  transition: opacity 0.2s ease;
}
.fade-enter-from, .fade-leave-to {
  opacity: 0;
}

.slide-up-enter-active, .slide-up-leave-active {
  transition: transform 0.35s cubic-bezier(0.16, 1, 0.3, 1), opacity 0.25s ease;
}
.slide-up-enter-from, .slide-up-leave-to {
  transform: translateY(30px);
  opacity: 0;
}

.toast-slide-enter-active, .toast-slide-leave-active {
  transition: transform 0.35s cubic-bezier(0.16, 1, 0.3, 1), opacity 0.25s ease;
}
.toast-slide-enter-from {
  transform: translateY(15px);
  opacity: 0;
}
.toast-slide-leave-to {
  transform: translateX(100px);
  opacity: 0;
}

/* Responsive Grid and elements */
@media (max-width: 640px) {
  .app-header {
    flex-direction: column;
    align-items: flex-start;
  }
  .btn-add {
    width: 100%;
  }
  .hero-banner {
    padding: 32px 24px;
  }
  .hero-headline {
    font-size: 1.8rem;
  }
  .pagination-section {
    flex-direction: column;
    align-items: center;
  }
}
</style>
