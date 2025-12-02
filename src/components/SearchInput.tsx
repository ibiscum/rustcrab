import React from "react";
import { Search } from "lucide-react";

type InputProps = React.InputHTMLAttributes<HTMLInputElement> & {
  error?: string;
};

const SearchInput: React.FC<InputProps> = ({
  placeholder,
  value,
  error,
  onChange,
  ...rest
}) => {
  return (
    <div className="relative">
      <input
        type="text"
        placeholder={placeholder}
        value={value}
        onChange={onChange}
        aria-label={placeholder || "Search"}
        aria-invalid={!!error}
        {...rest}
        className="w-full p-3 pl-10 rounded-full border border-gray-300 dark:border-gray-700 bg-white dark:bg-gray-800 text-gray-900 dark:text-white focus:outline-none focus:ring-2 focus:ring-red-500"
      />
      <Search
        className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400"
        size={20}
        aria-hidden="true"
      />
    </div>
  );
};

export default SearchInput;
