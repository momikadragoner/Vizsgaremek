import { Component, OnInit } from '@angular/core';
import { ProductService, ProductShort as Product } from 'src/app/services/product.service';

@Component({
  selector: 'app-best',
  templateUrl: './best.component.html',
  styleUrls: ['./best.component.scss']
})
export class BestComponent implements OnInit {

  bestProducts: Product[] = [{productId: 0, name: "", sellerLastName: "", sellerFirstName: "", price: -1, imgUrl:''}];
  pickedProducts: Product[] = [{productId: 0, name: "", sellerLastName: "", sellerFirstName: "", price: -1, imgUrl:''}];
  error: string = "";
  headerCard:boolean = true;

  constructor(private productService: ProductService) { }

  ngOnInit(): void {
    this.productService.getProducts('editors-picks').subscribe({
      next: data => {
        this.pickedProducts = [...data];
      }
    })
    this.productService.getProducts('best').subscribe({
      next: data => {
        this.bestProducts = [...data];
      }
    })
  }
}
