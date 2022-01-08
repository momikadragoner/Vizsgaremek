import { Component, OnInit } from '@angular/core';
import { faSearch } from '@fortawesome/free-solid-svg-icons';
import { faChevronDown } from '@fortawesome/free-solid-svg-icons';
import { ProductShort as Product, ProductListService as ProductService } from "../model/product";

@Component({
  selector: 'app-front-page',
  templateUrl: './front-page.component.html',
  styleUrls: ['./front-page.component.scss']
})
export class FrontPageComponent implements OnInit {

  faSearch = faSearch;
  faChevronDown = faChevronDown;

  products: Product[] = [{ id: 0, name: "", seller: "", price: 0, discountAvailable: false, imgUrl: ""}];
  error: string = "";

  constructor(private productService: ProductService) { }

  ngOnInit(): void {
    this.ShowProductList();
  }

  ShowProductList() {
    this.productService.getProductListLong()
    .subscribe((data: [Product]) => this.products = [...data], error => this.error = error);
  }

}
