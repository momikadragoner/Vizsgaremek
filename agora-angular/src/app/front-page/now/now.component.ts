import { Component, OnInit } from '@angular/core';
import { faAppleAlt, faChevronDown, faCocktail, faCookie, faNewspaper, faSearch } from '@fortawesome/free-solid-svg-icons';
import { ProductService, ProductShort as Product } from 'src/app/services/product.service';

@Component({
  selector: 'app-now',
  templateUrl: './now.component.html',
  styleUrls: ['./now.component.scss']
})
export class NowComponent implements OnInit {

  faSearch = faSearch;
  faChevronDown = faChevronDown;
  faNewspaper = faNewspaper;

  products: Product[] = [{productId: 0, name: "", sellerLastName: "", sellerFirstName: "", price: -1, imgUrl:''}];

  constructor(private productService: ProductService) { }

  ngOnInit(): void {
    this.productService.getProducts('now').subscribe({
      next: data => {
        this.products = [...data];
      }
    })
  }

}
