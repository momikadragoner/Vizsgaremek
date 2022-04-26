import { Component, OnInit } from '@angular/core';
import { faSearch } from '@fortawesome/free-solid-svg-icons';
import { faChevronDown } from '@fortawesome/free-solid-svg-icons';
import { ProductShort as Product, ProductService } from "../services/product.service";

@Component({
  selector: 'app-front-page',
  templateUrl: './front-page.component.html',
  styleUrls: ['./front-page.component.scss']
})
export class FrontPageComponent implements OnInit {

  faSearch = faSearch;
  faChevronDown = faChevronDown;

  products: Product[] = [{productId: 0, name: "", sellerLastName: "", sellerFirstName: "", price: -1, imgUrl:''}];
  error: string = "";

  constructor(private productService: ProductService) { }

  ngOnInit(): void {
    this.ShowProductList();
  }

  ShowProductList() {
    this.productService.getAllProducts()
    .subscribe({
      next: (data: [Product]) => {this.products = [...data]},
      error: error => this.error = error
    });
  }

}
