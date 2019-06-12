import Vue from 'vue'
import App from './App.vue'
import router from './router'
import BootstrapVue from 'bootstrap-vue'
import 'bootstrap/dist/css/bootstrap.css'
import VueToasted from 'vue-toasted';


Vue.config.productionTip = false

// Bootstrap
Vue.use(BootstrapVue)
Vue.use(VueWait)
Vue.use(VueToasted)


new Vue({
    router,
    render: h => h(App),
    wait: new VueWait(),
}).$mount('#app')

import VueWait from 'vue-wait'

