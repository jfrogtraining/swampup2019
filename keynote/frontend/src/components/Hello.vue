<template>
  <div class="hello">
    <div style="height:7em"></div>
    <img alt="frog" src="./../assets/swampuplogo-1.png" class="responsive"/>    <div style="height:2em"></div>
    <h1 class="elementor-heading-title elementor-size-default">BECOME A LEAN, MEAN <span style="color:#40be46;&quot;">DEVOPS MACHINE</span></h1>  </div>
</template>

<script>
export default {
  name: 'hello',
  props: { hellomsg: { type: String, required: true } }
}

</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped>
  @media screen and (max-width:1024px){
    img.responsive {width: 300px;}
  }

  @media screen and (min-width:1025px){
    img.responsive{width: 600px;}
  }

  img.responsive{height: auto;}

h1, h2 {
  font-weight: normal;
  color: white;
}

ul {
  list-style-type: none;
  padding: 0;
}

li {
  display: inline-block;
  margin: 0 10px;
}

a {
  color: #42b983;
}
</style>
