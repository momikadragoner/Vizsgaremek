import { Component, OnInit } from '@angular/core';
import { FormArray, FormBuilder, Validators } from '@angular/forms';
import { ActivatedRoute, Router, UrlSerializer } from '@angular/router';
import { FaIconLibrary } from '@fortawesome/angular-fontawesome';
import { faAppleAlt, faBalanceScale, faBreadSlice, faCarrot, faCheese, faExclamationCircle, faFilter, faGem, faGlassMartiniAlt, faHandPaper, faHeart, faMinus, faPalette, faPlus, faSearch, faShoppingCart, faSpinner, faTrash, faTree, faTshirt, IconPrefix } from '@fortawesome/free-solid-svg-icons';
import { ProductShort as Product, ProductService, tags } from '../services/product.service'
import { HttpParams } from '@angular/common/http';

@Component({
  selector: 'app-search',
  templateUrl: './search.component.html',
  styleUrls: ['./search.component.scss']
})
export class SearchComponent implements OnInit {

  products: Product[] = [new Product()];
  error: string = "";
  tagsList = tags;
  params:any;
  isLoading = false;

  iconPrefix: IconPrefix = 'fas';
  faCarrot = faCarrot;
  faBread = faBreadSlice;
  faApple = faAppleAlt;
  faCheese = faCheese;
  faPalette = faPalette;
  faGem = faGem;
  faTshirt = faTshirt;
  faGlassMartiniAlt = faGlassMartiniAlt;
  faShoppingCart = faShoppingCart;
  faPlus = faPlus;
  faMinus = faMinus;
  faFilter = faFilter;
  faTrash = faTrash;
  faSpinner = faSpinner;

  constructor(
    private productService: ProductService,
    private library: FaIconLibrary,
    private fb: FormBuilder,
    private route: ActivatedRoute,
    private router: Router,
    private serializer: UrlSerializer
  ) {
    library.addIcons(faHeart, faSpinner, faShoppingCart, faHandPaper, faTree, faBalanceScale, faExclamationCircle, faGem, faCarrot, faCheese, faAppleAlt, faBreadSlice, faGlassMartiniAlt, faPalette, faTshirt);
    this.tagsList.forEach(()=>{
      this.tags.push(this.fb.control(''));
    })
    this.ShowProductList();
    route.queryParams.subscribe(param => this.params = { ...param['keys'], ...param });
    if (this.params.category) {
      // console.log(this.params.category);
      this.categories[this.categories.indexOf(this.categories.filter(x => x.name == this.params.category)[0])].selected = true;
      this.filter();
    }
  }

  filterForm = this.fb.group({
    minPrice: [null],
    maxPrice: [null],
    tags: this.fb.array([
    ]),
    inStock: [null],
    madeOnDemand: [null],
    discount: [null],
  });

  get tags() {
    return this.filterForm.get('tags') as FormArray;
  }

  ngOnInit(): void {
  }

  ShowProductList() {
    this.productService.getAllProducts()
      .subscribe({
        next: (data: [Product]) => {
          this.products = [...data];
        },
        error: (error) => this.error = error
      });
  }

  selectCategory(id: number) {
    this.categories[id].selected = !this.categories[id].selected;
  }

  filter() {
    this.isLoading = true;
    let queryParams:{[k: string]: any} = {};
    this.categories.forEach( category => {
      queryParams[category.name] = category.selected;
    })
    let form = this.filterForm.value
    queryParams['maxPrice'] = form.maxPrice;
    queryParams['minPrice'] = form.minPrice;
    queryParams['inStock'] = form.inStock;
    queryParams['madeOnDemand'] = form.madeOnDemand;
    queryParams['discount'] = form.discount;
    for (let i = 0; i < form.tags.length; i++) {
      queryParams[this.tagsList[i]] = form.tags[i];
    }

    const tree = this.router.createUrlTree([], { queryParams: queryParams });
    this.productService.searchProducts(this.serializer.serialize(tree)).subscribe({
      next: data => {
        this.products = [...data];
        this.isLoading = false;
      },
      error: error => {
        this.isLoading = false;
      }
    });
  }

  deleteFilter() {
    this.categories.forEach( category => {
      category.selected = false;
    })
    this.tags.clear()
    this.tagsList.forEach(()=>{
      this.tags.push(this.fb.control(''));
    })
    let form = this.filterForm.value;
    form.maxPrice = null;
    form.minPrice = null;
    form.inStock = null;
    form.madeOnDemand = null;
    form.discount = null;
    this.filterForm.setValue(form);
  }

  categories = [
    { name: "Zöldség", selected: false },
    { name: "Gyümölcs", selected: false },
    { name: "Pékáru", selected: false },
    { name: "Tejtermék", selected: false },
    { name: "Ital", selected: false },
    { name: "Ékszer", selected: false },
    { name: "Művészet", selected: false },
    { name: "Divat", selected: false },
    { name: "Kamra", selected: false },
    { name: "Húsáru", selected: false }
  ]

}
