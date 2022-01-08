import { Component, OnInit } from '@angular/core';
import { ProductShort as Product, ProductListService as ProductService, tags} from '../model/product'

@Component({
  selector: 'app-search',
  templateUrl: './search.component.html',
  styleUrls: ['./search.component.scss']
})
export class SearchComponent implements OnInit {
  
  products: Product[] = [{ id: 0, name: "", seller: "", price: 0, discountAvailable: false, imgUrl: ""}];
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
