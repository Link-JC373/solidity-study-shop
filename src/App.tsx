import { defineComponent, onMounted, ref } from 'vue'
import getWeb3 from './utils/getWeb3'
import EcommerceStore from './contracts/EcommerceStore.json'
import { Button } from 'ant-design-vue'

interface IProduct {
  id: string
  name: string
  category: string
  imageLink: string
  descLink: string
  auctionStartTime: string
  auctionEndTime: string
  startPrice: string
  status: string
  condition: string
}

export default defineComponent({
  name: 'App',
  setup() {
    const contract = ref<any>()
    const accounts = ref<string>('')
    const products = ref<Array<IProduct>>([])

    const initWeb3 = async () => {
      const web3 = await getWeb3()
      accounts.value = await web3.eth.getAccounts()
      const networkId = await web3.eth.net.getId()
      const deployedNetwork = EcommerceStore.networks[networkId]
      contract.value = new web3.eth.Contract(
        EcommerceStore.abi,
        deployedNetwork && deployedNetwork.address
      )
    }
    onMounted(async () => {
      await initWeb3()
      await getProduct(1)
      await getProduct(2)
    })

    const getProduct = async (id: number) => {
      const res = await contract.value.methods.getProduct(id).call()
      const resName = res[0]
      const resData = res[1]
      const obj: any = {}
      // console.log(resName, resData);

      resName.forEach((value: string, index: number) => {
        obj[value] = resData[index]
      })
      console.log(obj)
      products.value.push(obj)
    }

    return {
      products,
    }
  },
  render() {
    return (
      <div>
        <Button>上传商品</Button>
        <div class={'products'}>
          {this.products.map((product) => (
              <div class={'product-container'}>
                <img src={"http://127.0.0.1:8080/ipfs/QmcZpHz83mcecpmiSnHd1miuF1jxh6sZhth8JCLUvpyCtq"} style={{width: '150px'}} alt="" />
                <p>{product.name}</p>
                <p>{product.category}</p>
                <p>{product.startPrice}</p>
                {/* <p>{product.name}</p>
                <p>{product.name}</p> */}
              </div>
          ))}
        </div>
      </div>
    )
  },
})
