import { Component, OnInit } from '@angular/core';
import { ProductShort as Product, ProductService, tags} from '../services/product.service'

@Component({
  selector: 'app-search',
  templateUrl: './search.component.html',
  styleUrls: ['./search.component.scss']
})
export class SearchComponent implements OnInit {
  
  products: Product[] = [{productId: 0, name: "", sellerLastName: "", sellerFirstName: "", price: -1, imgUrl:''}];
  error: string = "";
  tags = tags;

  constructor(private productService: ProductService) { }

  ngOnInit(): void {
    this.ShowProductList();
  }

  ShowProductList() {
    this.productService.getProductListLong()
    .subscribe((data: [Product]) => this.products = [...data], error => this.error = error);
  }

}
